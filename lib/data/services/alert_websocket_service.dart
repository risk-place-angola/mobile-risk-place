import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:rpa/constants.dart';
import 'package:rpa/data/models/enums/websocket_event_type.dart';
import 'package:rpa/data/models/websocket/websocket_message.dart';
import 'package:rpa/data/models/websocket/nearby_user_model.dart';
import 'package:rpa/data/providers/repository_providers.dart';

final alertWebSocketProvider = Provider((ref) => AlertWebSocketService());

class AlertWebSocketService with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  String? _currentToken;
  String? _currentDeviceId;
  Timer? _locationUpdateTimer;
  
  Function(Map<String, dynamic>)? onAlertReceived;
  Function(List<NearbyUserModel>)? onNearbyUsersReceived;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  AlertWebSocketService() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      developer.log('App paused, disconnecting WebSocket', name: 'AlertWebSocketService');
      disconnect();
    } else if (state == AppLifecycleState.resumed) {
      developer.log('App resumed, reconnecting WebSocket', name: 'AlertWebSocketService');
      if (_currentToken != null || _currentDeviceId != null) {
        connect(
          token: _currentToken,
          deviceId: _currentDeviceId,
        );
      }
    }
  }

  void connect({
    String? token,
    String? deviceId,
    Function(Map<String, dynamic>)? onAlert,
    Function(List<NearbyUserModel>)? onNearbyUsers,
    Function(String)? onError,
    Function()? onConnected,
    Function()? onDisconnected,
  }) {
    String? authToken = token ?? AuthTokenManager().token;
    _currentDeviceId = deviceId;
    
    if (authToken == null && (deviceId == null || deviceId.isEmpty)) {
      developer.log('No authentication credentials provided', name: 'AlertWebSocketService');
      onError?.call('No authentication credentials provided');
      return;
    }
    
    _tryConnect(
      authToken, 
      deviceId,
      0, 
      onAlert: onAlert,
      onNearbyUsers: onNearbyUsers,
      onError: onError,
      onConnected: onConnected,
      onDisconnected: onDisconnected,
    );
  }

  void _tryConnect(
    String? token,
    String? deviceId,
    int attempt, {
    Function(Map<String, dynamic>)? onAlert,
    Function(List<NearbyUserModel>)? onNearbyUsers,
    Function(String)? onError,
    Function()? onConnected,
    Function()? onDisconnected,
  }) async {
    if (attempt >= 5) {
      developer.log('Failed to connect after 5 attempts', name: 'AlertWebSocketService');
      onError?.call('Failed to connect after 5 attempts');
      return;
    }

    try {
      if (_channel != null && _currentToken == token) {
        developer.log('Already connected', name: 'AlertWebSocketService');
        return;
      }

      disconnect();

      if (onAlert != null) this.onAlertReceived = onAlert;
      if (onNearbyUsers != null) this.onNearbyUsersReceived = onNearbyUsers;
      if (onError != null) this.onError = onError;
      if (onConnected != null) this.onConnected = onConnected;
      if (onDisconnected != null) this.onDisconnected = onDisconnected;

      final fullUrl = WS_URL;
      developer.log('Connecting to: $fullUrl', name: 'AlertWebSocketService');
      
      final headers = <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else if (deviceId != null && deviceId.isNotEmpty) {
        headers['X-Device-ID'] = deviceId;
      }

      _channel = IOWebSocketChannel.connect(
        Uri.parse(fullUrl),
        headers: headers,
      );
      _currentToken = token;

      _channel?.stream.listen(
        (message) => _handleMessage(message),
        onDone: () => _onDone(token, deviceId, attempt),
        onError: (error) => _onError(token, deviceId, error, attempt),
      );

      developer.log('Connected successfully', name: 'AlertWebSocketService');
      try {
        onConnected?.call();
      } catch (e) {
        developer.log('Error in onConnected callback: $e', name: 'AlertWebSocketService');
      }
    } catch (e) {
      developer.log('Failed to connect: $e', name: 'AlertWebSocketService');
      await _handleReconnect(token, deviceId, attempt, 
        onAlert: onAlert,
        onNearbyUsers: onNearbyUsers,
        onError: onError,
        onConnected: onConnected,
        onDisconnected: onDisconnected,
      );
    }
  }

  void updateLocation(
    double latitude, 
    double longitude, {
    double? speed,
    double? heading,
  }) {
    try {
      if (_channel == null) {
        developer.log('Cannot update location: WebSocket not connected', name: 'AlertWebSocketService');
        return;
      }

      final locationUpdateData = LocationUpdateData(
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
      );

      final locationMessage = WebSocketMessage(
        event: WebSocketEventType.updateLocation,
        data: locationUpdateData,
      );

      final jsonMessage = jsonEncode(locationMessage.toJson((data) => data.toJson()));
      
      _channel?.sink.add(jsonMessage);
      developer.log('Location update sent: ($latitude, $longitude)', name: 'AlertWebSocketService');
    } catch (e) {
      developer.log('Error updating location: $e', name: 'AlertWebSocketService');
    }
  }

  void startLocationUpdates({
    required double latitude,
    required double longitude,
    required Function() getCurrentLocation,
    int intervalSeconds = 30,
  }) {
    // Cancel previous timer if exists
    stopLocationUpdates();

    // Send initial location
    updateLocation(latitude, longitude);

    // Start periodic updates
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) {
        try {
          // Call the callback to get current location
          getCurrentLocation();
        } catch (e) {
          developer.log('Error in location update callback: $e', name: 'AlertWebSocketService');
        }
      },
    );

    developer.log('Started location updates: ${intervalSeconds}s interval', 
        name: 'AlertWebSocketService');
  }

  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    developer.log('Stopped automatic location updates', name: 'AlertWebSocketService');
  }

  void _handleMessage(String message) {
    try {
      final decodedMessage = jsonDecode(message);
      final event = decodedMessage['event'] as String?;
      final type = decodedMessage['type'] as String?;

      if (event == 'nearby_users') {
        _handleNearbyUsers(decodedMessage['data'] as Map<String, dynamic>);
      } else if (type == 'alert' || event == 'alert') {
        final alertData = decodedMessage['data'] as Map<String, dynamic>;
        developer.log('Alert received: ${alertData['message']}', name: 'AlertWebSocketService');
        try {
          onAlertReceived?.call(alertData);
        } catch (e) {
          developer.log('Error in onAlertReceived callback: $e', name: 'AlertWebSocketService');
        }
      } else if (type == 'error') {
        final errorMessage = decodedMessage['message'] as String;
        developer.log('Server error: $errorMessage', name: 'AlertWebSocketService');
        try {
          onError?.call(errorMessage);
        } catch (e) {
          developer.log('Error in onError callback: $e', name: 'AlertWebSocketService');
        }
      } else if (event == 'location_updated' || event == 'location_update_failed') {
        return;
      } else {
        developer.log('Unknown message type: $type, event: $event', name: 'AlertWebSocketService');
      }
    } catch (e) {
      developer.log('Error handling message: $e', name: 'AlertWebSocketService');
      try {
        onError?.call('Error processing message: $e');
      } catch (callbackError) {
        developer.log('Error in onError callback: $callbackError', name: 'AlertWebSocketService');
      }
    }
  }

  void _handleNearbyUsers(Map<String, dynamic> data) {
    try {
      final usersJson = data['users'] as List<dynamic>;
      final users = usersJson
          .map((json) => NearbyUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      developer.log('Received ${users.length} nearby users', name: 'AlertWebSocketService');
      
      try {
        onNearbyUsersReceived?.call(users);
      } catch (e) {
        developer.log('Error in onNearbyUsersReceived callback: $e', name: 'AlertWebSocketService');
      }
    } catch (e) {
      developer.log('Error parsing nearby users: $e', name: 'AlertWebSocketService');
    }
  }

  void _onDone(String? token, String? deviceId, int attempt) {
    developer.log('Connection closed', name: 'AlertWebSocketService');
    try {
      onDisconnected?.call();
    } catch (e) {
      developer.log('Error in onDisconnected callback: $e', name: 'AlertWebSocketService');
    }
    _handleReconnect(token, deviceId, attempt);
  }

  void _onError(String? token, String? deviceId, error, int attempt) {
    developer.log('Connection error: $error', name: 'AlertWebSocketService');
    try {
      onError?.call('Connection error: $error');
    } catch (e) {
      developer.log('Error in onError callback: $e', name: 'AlertWebSocketService');
    }
    _handleReconnect(token, deviceId, attempt);
  }

  Future<void> _handleReconnect(
    String? token,
    String? deviceId,
    int attempt, {
    Function(Map<String, dynamic>)? onAlert,
    Function(List<NearbyUserModel>)? onNearbyUsers,
    Function(String)? onError,
    Function()? onConnected,
    Function()? onDisconnected,
  }) async {
    if (attempt < 5) {
      final delay = pow(2, attempt).toInt();
      developer.log('Retrying connection in ${delay}s (attempt ${attempt + 1}/5)', name: 'AlertWebSocketService');
      await Future.delayed(Duration(seconds: delay));
      _tryConnect(token, deviceId, attempt + 1,
        onAlert: onAlert,
        onNearbyUsers: onNearbyUsers,
        onError: onError,
        onConnected: onConnected,
        onDisconnected: onDisconnected,
      );
    }
  }

  void disconnect() {
    try {
      stopLocationUpdates();
      
      if (_channel != null) {
        _channel!.sink.close();
        _channel = null;
        _currentToken = null;
        _currentDeviceId = null;
        developer.log('Disconnected from WebSocket', name: 'AlertWebSocketService');
        try {
          onDisconnected?.call();
        } catch (e) {
          developer.log('Error in onDisconnected callback: $e', name: 'AlertWebSocketService');
        }
      }
    } catch (e) {
      developer.log('Error disconnecting: $e', name: 'AlertWebSocketService');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
  }

  bool get isConnected => _channel != null;
}
