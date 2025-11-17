import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/managers/anonymous_user_manager.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/presenter/pages/map/map_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    
    ref.read(authControllerProvider).initialize();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeAnonymousUser();
        ref.read(locationControllerProvider).requestLocationPermission();
      }
    });
  }

  Future<void> _initializeAnonymousUser() async {
    try {
      log('🌟 [HomePage] Initializing anonymous user (Waze-style)');
      final manager = ref.read(anonymousUserManagerProvider);
      await manager.initialize();
    } catch (e) {
      log('❌ [HomePage] Anonymous initialization error: $e');
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
