import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rpa/core/device/device_id_manager.dart';
import 'package:rpa/data/services/device.service.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/data/services/location.service.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/data/dtos/device_dto.dart';

final anonymousUserManagerProvider = Provider((ref) {
  final deviceService = ref.read(deviceServiceProvider);
  final wsService = ref.read(alertWebSocketProvider);
  final locationService = ref.read(locationServiceProvider);
  
  return AnonymousUserManager(
    deviceService: deviceService,
    wsService: wsService,
    locationService: locationService,
  );
});

class AnonymousUserManager {
  final DeviceIdManager _deviceIdManager = DeviceIdManager();
  final DeviceService _deviceService;
  final AlertWebSocketService _wsService;
  final LocationService _locationService;
  
  String? _deviceId;
  String? _fcmToken;
  Timer? _locationUpdateTimer;
  
  AnonymousUserManager({
    required DeviceService deviceService,
    required AlertWebSocketService wsService,
    required LocationService locationService,
  })  : _deviceService = deviceService,
        _wsService = wsService,
        _locationService = locationService;
  
  Future<void> initialize() async {
    try {
      log('🚀 Initializing anonymous user system', name: 'AnonymousUserManager');
      
      _deviceId = await _deviceIdManager.getDeviceId();
      
      final hasPermission = await _locationService.handleLocationPermission();
      if (!hasPermission) {
        log('⚠️ Location permission denied', name: 'AnonymousUserManager');
      }
      
      try {
        _fcmToken = await _getFCMToken();
        log('✅ FCM token obtained: $_fcmToken', name: 'AnonymousUserManager');
      } catch (e) {
        log('⚠️ FCM token error: $e', name: 'AnonymousUserManager');
        log('ℹ️ App will retry FCM token in background', name: 'AnonymousUserManager');
      }
      
      await _registerDevice();
      await _connectWebSocket();
      _startLocationTracking();
      
      log('✅ Anonymous user system initialized', name: 'AnonymousUserManager');
    } catch (e) {
      log('❌ Initialization error: $e', name: 'AnonymousUserManager');
      rethrow;
    }
  }
  
  Future<void> _registerDevice() async {
    final position = await _locationService.getCurrentPosition();
    
    final request = DeviceRegisterRequestDTO(
      deviceId: _deviceId!,
      fcmToken: _fcmToken,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
    
    await _deviceService.registerDevice(request: request);
    log('✅ Device registered', name: 'AnonymousUserManager');
  }
  
  Future<void> _connectWebSocket() async {
    _wsService.connect(
      deviceId: _deviceId,
      onAlert: (alert) {
        log('🚨 Alert: ${alert['message']}', name: 'AnonymousUserManager');
      },
      onError: (error) {
        log('❌ WebSocket error: $error', name: 'AnonymousUserManager');
      },
      onConnected: () {
        log('✅ WebSocket connected', name: 'AnonymousUserManager');
      },
      onDisconnected: () {
        log('🔌 WebSocket disconnected', name: 'AnonymousUserManager');
      },
    );
  }
  
  void _startLocationTracking() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          _wsService.updateLocation(position.latitude, position.longitude);
          
          final request = UpdateDeviceLocationDTO(
            deviceId: _deviceId!,
            latitude: position.latitude,
            longitude: position.longitude,
          );
          
          try {
            await _deviceService.updateLocation(request: request);
          } catch (e) {
            log('❌ Location update error: $e', name: 'AnonymousUserManager');
          }
        }
      },
    );
  }
  
  void dispose() {
    _locationUpdateTimer?.cancel();
    _wsService.disconnect();
  }
  
  String? get deviceId => _deviceId;
  
  Future<String?> _getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) return token;
      
      log('⏳ FCM token null, waiting 2s for APNS token...', name: 'AnonymousUserManager');
      await Future.delayed(const Duration(seconds: 2));
      
      token = await FirebaseMessaging.instance.getToken();
      if (token != null) return token;
      
      log('⏳ Retrying FCM token after 3s...', name: 'AnonymousUserManager');
      await Future.delayed(const Duration(seconds: 3));
      
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      log('❌ Error getting FCM token: $e', name: 'AnonymousUserManager');
      return null;
    }
  }
}
