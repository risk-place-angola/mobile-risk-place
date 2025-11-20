import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/managers/anonymous_user_manager.dart';
import 'package:rpa/core/services/permission_service.dart';
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
      log('Initializing app resources', name: 'HomePage');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!_permissionsRequested && mounted) {
        _permissionsRequested = true;
        await _requestPermissions();
      }

      if (mounted) {
        await _initializeAnonymousUser();
      }
    } catch (e) {
      log('App initialization error: $e', name: 'HomePage');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      log('Requesting permissions after home screen loaded', name: 'HomePage');

      final permissionService = ref.read(permissionServiceProvider);

      await permissionService.requestNotificationPermission();

      final locationController = ref.read(locationControllerProvider);
      final locationGranted =
          await locationController.requestLocationPermission();

      if (locationGranted) {
        log('Location permission granted', name: 'HomePage');
        locationController.startLocationUpdates();
      } else {
        log('Location permission denied or failed', name: 'HomePage');
      }
    } catch (e) {
      log('Error requesting permissions: $e', name: 'HomePage');
    }
  }

  Future<void> _initializeAnonymousUser() async {
    try {
      log('Initializing anonymous user', name: 'HomePage');
      final manager = ref.read(anonymousUserManagerProvider);
      await manager.initialize();
    } catch (e) {
      log('Anonymous initialization error: $e', name: 'HomePage');
    }
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
