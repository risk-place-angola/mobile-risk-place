import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:rpa/constants.dart';
import 'package:rpa/data/models/enums/websocket_event_type.dart';
import 'package:rpa/data/models/websocket/websocket_message.dart';
import 'package:rpa/data/models/websocket/nearby_user_model.dart';
import 'package:rpa/data/providers/repository_providers.dart';

final alertWebSocketProvider = Provider((ref) => AlertWebSocketService());

/// WebSocket service for real-time alerts
/// 
/// 🌟 WAZE-STYLE: Works with or without authentication!
/// - Anonymous users can send location and receive public alerts
/// - Authenticated users get personalized alerts and additional features
class AlertWebSocketService {
  WebSocketChannel? _channel;
  String? _currentToken;
  Timer? _locationUpdateTimer;
  
  Function(Map<String, dynamic>)? onAlertReceived;
  Function(List<NearbyUserModel>)? onNearbyUsersReceived;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

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
    
    if (authToken != null && authToken.isNotEmpty) {
      log('🔐 [WebSocket] Authenticated connection (JWT)', name: 'AlertWebSocketService');
    } else if (deviceId != null && deviceId.isNotEmpty) {
      log('🌐 [WebSocket] Anonymous connection (device_id)', name: 'AlertWebSocketService');
    } else {
      log('❌ [WebSocket] No JWT or device_id provided', name: 'AlertWebSocketService');
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
    if (attempt >= 3) {
      log('❌ [WebSocket] Failed to connect after 3 attempts', name: 'AlertWebSocketService');
      onError?.call('Failed to connect after 3 attempts');
      return;
    }

    try {
      if (_channel != null && _currentToken == token) {
        log('ℹ️ [WebSocket] Already connected', name: 'AlertWebSocketService');
        return;
      }

      disconnect();

      // Only update callbacks if they are provided (don't overwrite with null)
      if (onAlert != null) this.onAlertReceived = onAlert;
      if (onNearbyUsers != null) this.onNearbyUsersReceived = onNearbyUsers;
      if (onError != null) this.onError = onError;
      if (onConnected != null) this.onConnected = onConnected;
      if (onDisconnected != null) this.onDisconnected = onDisconnected;

      // 🎯 Use WS_URL directly from environment variables
      final fullUrl = WS_URL;

      log('📡 [WebSocket] Connecting to: $fullUrl', name: 'AlertWebSocketService');
      
      // 🔐 Create WebSocket with Authorization header (if authenticated) or X-Device-ID (if anonymous)
      final headers = <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        log('🔑 [WebSocket] Authorization: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...', 
            name: 'AlertWebSocketService');
      } else if (deviceId != null && deviceId.isNotEmpty) {
        headers['X-Device-ID'] = deviceId;
        log('🌐 [WebSocket] X-Device-ID: $deviceId', 
            name: 'AlertWebSocketService');
      } else {
        log('🌐 [WebSocket] No authentication headers', 
            name: 'AlertWebSocketService');
      }

      // Connect with headers
      _channel = IOWebSocketChannel.connect(
        Uri.parse(fullUrl),
        headers: headers,
      );
      _currentToken = token;

      // Listen to messages
      _channel?.stream.listen(
        (message) => _handleMessage(message),
        onDone: () => _onDone(token, deviceId, attempt),
        onError: (error) => _onError(token, deviceId, error, attempt),
      );

      log('✅ [WebSocket] Connected successfully!', name: 'AlertWebSocketService');
      onConnected?.call();
    } catch (e) {
      log('❌ [WebSocket] Failed to connect: $e', name: 'AlertWebSocketService');
      await _handleReconnect(token, deviceId, attempt, 
        onAlert: onAlert,
        onNearbyUsers: onNearbyUsers,
        onError: onError,
        onConnected: onConnected,
        onDisconnected: onDisconnected,
      );
    }
  }



  /// Update user location for proximity alerts
  /// Call this periodically to receive alerts near the user
  /// Uses the format: { "event": "update_location", "data": { "latitude": -8.842560, "longitude": 13.300120, "speed": 0, "heading": 0 } }
  void updateLocation(
    double latitude, 
    double longitude, {
    double? speed,
    double? heading,
  }) {
    try {
      if (_channel == null) {
        log('⚠️ [WebSocket] Cannot update location: WebSocket not connected', name: 'AlertWebSocketService');
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
      log('📍 [WebSocket] Location update sent: ($latitude, $longitude, speed: $speed, heading: $heading)', name: 'AlertWebSocketService');
      log('📤 [WebSocket] Message: $jsonMessage', name: 'AlertWebSocketService');
    } catch (e) {
      log('❌ [WebSocket] Error updating location: $e', name: 'AlertWebSocketService');
    }
  }

  /// Start automatic location updates (best practice like Waze)
  /// Updates location every [intervalSeconds] seconds
  void startLocationUpdates({
    required double latitude,
    required double longitude,
    required Function() getCurrentLocation,
    int intervalSeconds = 30, // Update every 30 seconds like Waze
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
          log('Error in location update callback: $e', name: 'AlertWebSocketService');
        }
      },
    );

    log('Started automatic location updates (every $intervalSeconds seconds)', 
        name: 'AlertWebSocketService');
  }

  /// Stop automatic location updates
  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    log('Stopped automatic location updates', name: 'AlertWebSocketService');
  }

  void _handleMessage(String message) {
    try {
      log('📩 [WebSocket] Raw message received: $message', name: 'AlertWebSocketService');
      
      final decodedMessage = jsonDecode(message);
      final event = decodedMessage['event'] as String?;
      final type = decodedMessage['type'] as String?;
      
      log('📨 [WebSocket] Message event: $event, type: $type', name: 'AlertWebSocketService');

      if (event == 'nearby_users') {
        _handleNearbyUsers(decodedMessage['data'] as Map<String, dynamic>);
      } else if (type == 'alert' || event == 'alert') {
        final alertData = decodedMessage['data'] as Map<String, dynamic>;
        log('🚨 [WebSocket] Alert received: ${alertData['message']}', name: 'AlertWebSocketService');
        onAlertReceived?.call(alertData);
      } else if (type == 'error') {
        final errorMessage = decodedMessage['message'] as String;
        log('❌ [WebSocket] Error from server: $errorMessage', name: 'AlertWebSocketService');
        onError?.call(errorMessage);
      } else {
        log('ℹ️ [WebSocket] Unknown message event: $event, type: $type', name: 'AlertWebSocketService');
      }
    } catch (e) {
      log('❌ [WebSocket] Error handling message: $e', name: 'AlertWebSocketService');
      onError?.call('Error processing message: $e');
    }
  }

  void _handleNearbyUsers(Map<String, dynamic> data) {
    try {
      final usersJson = data['users'] as List<dynamic>;
      final users = usersJson
          .map((json) => NearbyUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      onNearbyUsersReceived?.call(users);
    } catch (e) {
      log('❌ [WebSocket] Error parsing nearby users: $e', name: 'AlertWebSocketService');
    }
  }

  void _onDone(String? token, String? deviceId, int attempt) {
    log('🔌 [WebSocket] Connection closed', name: 'AlertWebSocketService');
    onDisconnected?.call();
    _handleReconnect(token, deviceId, attempt);
  }

  void _onError(String? token, String? deviceId, error, int attempt) {
    log('❌ [WebSocket] Connection error: $error', name: 'AlertWebSocketService');
    onError?.call('Connection error: $error');
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
    final delayDurations = [1, 5, 8];
    if (attempt < delayDurations.length) {
      final delay = delayDurations[attempt];
      log('🔄 [WebSocket] Retrying connection in $delay seconds...', name: 'AlertWebSocketService');
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

  /// Disconnect from WebSocket
  void disconnect() {
    try {
      stopLocationUpdates();
      
      if (_channel != null) {
        _channel!.sink.close();
        _channel = null;
        _currentToken = null;
        log('Disconnected from WebSocket', name: 'AlertWebSocketService');
        onDisconnected?.call();
      }
    } catch (e) {
      log('Error disconnecting from WebSocket: $e', name: 'AlertWebSocketService');
    }
  }

  bool get isConnected => _channel != null;
}
