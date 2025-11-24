import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/local_storage/hive_config.dart';
import 'package:rpa/core/services/fcm_service.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/providers/repository_providers.dart';
import 'package:rpa/firebase_options.dart';

import 'app_widget.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final fcmService = FCMService();
    await fcmService.initialize();
    
    await fcmService.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await HiveConfig.initialize();
    
    _restoreAuthenticationState();

    runApp(
      ProviderScope(
        child: AppWidget(),
      ),
    );
  } catch (e) {
    log('Initialization error: $e', name: 'Main');
  }
}

void _restoreAuthenticationState() {
  Future.microtask(() async {
    try {
      final box = Hive.box(BDCollections.USERS);
      final userData = box.get('user');
      
      if (userData == null) {
        log('No stored authentication found', name: 'Main');
        return;
      }

      final authData = AuthTokenResponseDTO.fromJson(
        Map<String, dynamic>.from(userData as Map)
      );

      if (authData.accessToken.isEmpty) {
        log('Empty access token in storage', name: 'Main');
        return;
      }

      AuthTokenManager().setToken(
        authData.accessToken,
        refreshToken: authData.refreshToken,
        expiresIn: authData.expiresIn,
      );

      log('Authentication state restored successfully', name: 'Main');
    } catch (e) {
      log('Failed to restore authentication: $e', name: 'Main');
    }
  });
}
