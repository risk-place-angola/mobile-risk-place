import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/services/notification_service.dart';
import 'package:rpa/core/managers/settings_manager.dart';
import 'package:rpa/data/providers/api_providers.dart';

final smartNotificationServiceProvider =
    Provider<SmartNotificationService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final settingsManager = ref.watch(settingsManagerProvider);
  return SmartNotificationService(notificationService, settingsManager);
});

class SmartNotificationService {
  final NotificationService _notificationService;
  final SettingsManager _settingsManager;

  SmartNotificationService(this._notificationService, this._settingsManager);

  Future<void> showAlertIfAllowed({
    required String title,
    required String message,
    required String severity,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    Map<String, dynamic>? data,
  }) async {
    final distance = _settingsManager.calculateDistance(
      userLatitude,
      userLongitude,
      latitude,
      longitude,
    );

    if (!_settingsManager.shouldNotifyAlert(severity, distance)) {
      log('Alert filtered: severity=$severity, distance=${distance.toStringAsFixed(0)}m',
          name: 'SmartNotificationService');
      return;
    }

    await _notificationService.showAlertNotification(
      title: title,
      message: message,
      severity: severity,
      data: data,
    );
  }

  Future<void> showReportIfAllowed({
    required String title,
    required String message,
    required String status,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    Map<String, dynamic>? data,
  }) async {
    final distance = _settingsManager.calculateDistance(
      userLatitude,
      userLongitude,
      latitude,
      longitude,
    );

    if (!_settingsManager.shouldNotifyReport(status, distance)) {
      log('Report filtered: status=$status, distance=${distance.toStringAsFixed(0)}m',
          name: 'SmartNotificationService');
      return;
    }

    await _notificationService.showReportNotification(
      title: title,
      message: message,
      status: status,
      data: data,
    );
  }

  Future<void> showDangerZoneWarning({
    required String title,
    required String message,
    required int incidentCount,
    Map<String, dynamic>? data,
  }) async {
    if (!_settingsManager.isDangerZonesEnabled) {
      return;
    }

    await _notificationService.showAlertNotification(
      title: title,
      message: message,
      severity: 'high',
      data: data,
    );

    log('Danger zone warning shown: $incidentCount incidents',
        name: 'SmartNotificationService');
  }
}
