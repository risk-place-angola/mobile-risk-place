import 'dart:developer';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionService {
  Future<void> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      if (status.isDenied) {
        final result = await Permission.microphone.request();
        if (result.isGranted) {
          log('Microphone permission granted', name: 'PermissionService');
        } else {
          log('Microphone permission denied', name: 'PermissionService');
        }
      }

      await RecorderController().checkPermission();
    } catch (e) {
      log('Error requesting microphone permission: $e',
          name: 'PermissionService');
    }
  }

  Future<bool> checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      log('Error checking microphone permission: $e',
          name: 'PermissionService');
      return false;
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final result = await Permission.notification.request();
        if (result.isGranted) {
          log('Notification permission granted', name: 'PermissionService');
        } else {
          log('Notification permission denied', name: 'PermissionService');
        }
      }
    } catch (e) {
      log('Error requesting notification permission: $e',
          name: 'PermissionService');
    }
  }

  Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      log('Error checking notification permission: $e',
          name: 'PermissionService');
      return false;
    }
  }

  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      log('Error opening app settings: $e', name: 'PermissionService');
    }
  }
}
