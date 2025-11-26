import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rpa/core/device/device_id_manager.dart';
import 'package:rpa/data/services/device.service.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/data/services/location.service.dart';
import 'package:rpa/data/providers/repository_providers.dart';
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
      log('✅ [AnonymousUserManager] Starting initialization (non-blocking)', name: 'AnonymousUserManager');

      // ✅ CORE: Device ID (always needed, fast)
      _deviceId = await _deviceIdManager.getDeviceId();
      log('✅ Device ID obtained: $_deviceId', name: 'AnonymousUserManager');

      // ✅ ENHANCEMENT: FCM token (background, non-blocking)
      _fetchFCMTokenInBackground();

      // ✅ ENHANCEMENT: WebSocket (fire-and-forget)
      _connectWebSocket();

      // ✅ Start location tracking immediately
      _startLocationTracking();

      // ✅ DELAYED: Device registration after 15s (gives API time to wake up, doesn't block UI)
      log('⏳ [AnonymousUserManager] Scheduling device registration for 15s from now...', name: 'AnonymousUserManager');
      Future.delayed(const Duration(seconds: 15), () {
        log('✅ [AnonymousUserManager] Starting delayed device registration', name: 'AnonymousUserManager');
        _registerDeviceInBackground();
      });

      log('✅ [AnonymousUserManager] Core initialization complete (enhancements in background)', name: 'AnonymousUserManager');
    } catch (e) {
      log('❌ [AnonymousUserManager] Initialization error: $e', name: 'AnonymousUserManager');
      // Don't rethrow - app should continue even if anonymous features fail
    }
  }

  void _fetchFCMTokenInBackground() {
    Future(() async {
      try {
        log('🔍 [AnonymousUserManager] Fetching FCM token in background...', name: 'AnonymousUserManager');
        
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          _fcmToken = token;
          log('✅ [AnonymousUserManager] FCM token obtained', name: 'AnonymousUserManager');
          // Try to update device registration with token
          _registerDeviceInBackground();
          return;
        }

        // Retry once after 2s (APNS needs time on iOS)
        log('⏳ [AnonymousUserManager] FCM token null, retrying after 2s...', name: 'AnonymousUserManager');
        await Future.delayed(const Duration(seconds: 2));
        
        token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          _fcmToken = token;
          log('✅ [AnonymousUserManager] FCM token obtained on retry', name: 'AnonymousUserManager');
          _registerDeviceInBackground();
        } else {
          log('⚠️ [AnonymousUserManager] FCM token unavailable, continuing without push notifications', name: 'AnonymousUserManager');
        }
      } catch (e) {
        log('❌ [AnonymousUserManager] FCM token error: $e', name: 'AnonymousUserManager');
      }
    });
  }

  void _registerDeviceInBackground() {
    Future(() async {
      try {
        await _registerDevice();
      } catch (e) {
        log('❌ [AnonymousUserManager] Device registration error: $e (non-critical)', name: 'AnonymousUserManager');
      }
    });
  }

  Future<void> _registerDevice() async {
    final position = await _locationService.getCurrentPosition();
    final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;

    log('Device language: $systemLocale', name: 'AnonymousUserManager');

    final request = DeviceRegisterRequestDTO(
      deviceId: _deviceId!,
      fcmToken: _fcmToken,
      language: systemLocale,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    await _deviceService.registerDevice(request: request);
    log('✅ Device registered', name: 'AnonymousUserManager');
  }

  void _connectWebSocket() {
    final authToken = AuthTokenManager().token;
    
    log('🔌 [AnonymousUserManager] Starting WebSocket connection (non-blocking)', name: 'AnonymousUserManager');
    
    if (authToken != null && authToken.isNotEmpty) {
      log('🔐 [AnonymousUserManager] Authenticated user detected, using JWT for WebSocket', name: 'AnonymousUserManager');
      _wsService.connect(
        token: authToken,
        onAlert: (alert) {
          log('Alert: ${alert['message']}', name: 'AnonymousUserManager');
        },
        onError: (error) {
          log('WebSocket error: $error', name: 'AnonymousUserManager');
        },
        onConnected: () {
          log('Connected', name: 'AnonymousUserManager');
        },
        onDisconnected: () {
          log('Disconnected', name: 'AnonymousUserManager');
        },
      );
    } else {
      log('🌐 [AnonymousUserManager] Anonymous user detected, using device_id for WebSocket', name: 'AnonymousUserManager');
      _wsService.connect(
        deviceId: _deviceId,
        onAlert: (alert) {
          log('Alert: ${alert['message']}', name: 'AnonymousUserManager');
        },
        onError: (error) {
          log('WebSocket error: $error', name: 'AnonymousUserManager');
        },
        onConnected: () {
          log('Connected', name: 'AnonymousUserManager');
        },
        onDisconnected: () {
          log('Disconnected', name: 'AnonymousUserManager');
        },
      );
    }
  }

  void _startLocationTracking() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          _wsService.updateLocation(
            position.latitude, 
            position.longitude,
            speed: position.speed,
            heading: position.heading,
          );
        }
      },
    );
  }

  void dispose() {
    _locationUpdateTimer?.cancel();
    _wsService.disconnect();
  }

  String? get deviceId => _deviceId;
  String? get fcmToken => _fcmToken;
}
