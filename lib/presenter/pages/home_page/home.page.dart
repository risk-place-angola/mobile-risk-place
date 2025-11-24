import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rpa/core/managers/anonymous_user_manager.dart';
import 'package:rpa/core/services/permission_service.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/data/providers/repository_providers.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/presenter/pages/map/map_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _permissionsRequested = false;
  bool _webSocketConnected = false;
  int _wsConnectionAttempts = 0;
  static const int _maxWsAttempts = 5;

  @override
  void initState() {
    super.initState();

    ref.read(authControllerProvider).initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      dev.log('Initializing app resources', name: 'HomePage');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!_permissionsRequested && mounted) {
        _permissionsRequested = true;
        await _requestPermissions();
      }

      if (mounted) {
        await _initializeAnonymousUser();
      }

      if (mounted) {
        await _connectWebSocket();
      }
    } catch (e) {
      dev.log('App initialization error: $e', name: 'HomePage');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      dev.log('Checking permissions', name: 'HomePage');

      final permissionService = ref.read(permissionServiceProvider);
      final locationController = ref.read(locationControllerProvider);

      final hasNotificationPermission = await permissionService.checkNotificationPermission();
      if (!hasNotificationPermission) {
        dev.log('Requesting notification permission', name: 'HomePage');
        await permissionService.requestNotificationPermission();
      } else {
        dev.log('Notification permission already granted', name: 'HomePage');
      }

      final locationService = ref.read(locationServiceProvider);
      final locationPermission = await locationService.checkPermission();
      
      if (locationPermission == LocationPermission.always || 
          locationPermission == LocationPermission.whileInUse) {
        dev.log('Location permission already granted', name: 'HomePage');
        locationController.startLocationUpdates();
      } else {
        dev.log('Requesting location permission', name: 'HomePage');
        final granted = await locationController.requestLocationPermission();
        if (granted) {
          dev.log('Location permission granted', name: 'HomePage');
          locationController.startLocationUpdates();
        } else {
          dev.log('Location permission denied', name: 'HomePage');
        }
      }
    } catch (e) {
      dev.log('Error checking permissions: $e', name: 'HomePage');
    }
  }

  Future<void> _initializeAnonymousUser() async {
    try {
      dev.log('Initializing anonymous user', name: 'HomePage');
      final manager = ref.read(anonymousUserManagerProvider);
      await manager.initialize();
    } catch (e) {
      dev.log('Anonymous initialization error: $e', name: 'HomePage');
    }
  }

  Future<void> _connectWebSocket() async {
    if (_webSocketConnected || _wsConnectionAttempts >= _maxWsAttempts) {
      if (_wsConnectionAttempts >= _maxWsAttempts) {
        dev.log('⚠️ [HomePage] WebSocket max attempts reached, continuing offline', name: 'HomePage');
        _showOfflineInfo();
      }
      return;
    }

    _wsConnectionAttempts++;
    
    try {
      dev.log('🔌 [HomePage] Connecting WebSocket (attempt $_wsConnectionAttempts/$_maxWsAttempts)', name: 'HomePage');
      
      final wsService = ref.read(alertWebSocketProvider);
      final authToken = AuthTokenManager().token;
      
      if (authToken != null && authToken.isNotEmpty) {
        dev.log('✅ [HomePage] Authenticated WebSocket connection', name: 'HomePage');
        
        wsService.connect(
          token: authToken,
          onConnected: () {
            if (mounted) {
              setState(() => _webSocketConnected = true);
              dev.log('✅ [HomePage] WebSocket connected successfully', name: 'HomePage');
              _wsConnectionAttempts = 0;
            }
          },
          onDisconnected: () {
            if (mounted) {
              setState(() => _webSocketConnected = false);
              dev.log('🔌 [HomePage] WebSocket disconnected', name: 'HomePage');
              _scheduleReconnect();
            }
          },
          onError: (error) {
            dev.log('❌ [HomePage] WebSocket error: $error', name: 'HomePage');
            if (mounted && _wsConnectionAttempts < _maxWsAttempts) {
              _scheduleReconnect();
            }
          },
        );
      } else {
        dev.log('🌐 [HomePage] No auth token, app continues offline', name: 'HomePage');
      }
    } catch (e) {
      dev.log('❌ [HomePage] WebSocket connection error: $e', name: 'HomePage');
      if (mounted && _wsConnectionAttempts < _maxWsAttempts) {
        _scheduleReconnect();
      }
    }
  }

  void _scheduleReconnect() {
    if (!mounted || _wsConnectionAttempts >= _maxWsAttempts) return;
    
    final delay = Duration(seconds: min(30, pow(2, _wsConnectionAttempts).toInt()));
    dev.log('🔄 [HomePage] Scheduling reconnect in ${delay.inSeconds}s', name: 'HomePage');
    
    Future.delayed(delay, () {
      if (mounted) _connectWebSocket();
    });
  }

  void _showOfflineInfo() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Real-time updates unavailable. App continues offline.'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // App opens directly on the map view with all Waze-style features:
    // - Hamburger menu (slide-out)
    // - Floating profile button
    // - Draggable home panel with search, quick actions, and recent items
    return Scaffold(
      body: const MapView(),
      // note: no BottomNavigationBar here
    );
  }
}
