import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/data/services/settings.service.dart';

final settingsManagerProvider = Provider<SettingsManager>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsManager(settingsService);
});

class SettingsManager {
  final SettingsService _settingsService;
  UserSettings? _cachedSettings;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  SettingsManager(this._settingsService);

  Future<UserSettings> getSettings({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedSettings != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedSettings!;
    }

    _cachedSettings =
        await _settingsService.getSettings(forceRefresh: forceRefresh);
    _lastFetch = DateTime.now();
    return _cachedSettings!;
  }

  bool shouldNotifyAlert(String severity, double distanceMeters) {
    if (_cachedSettings == null || !_cachedSettings!.notificationsEnabled) {
      return false;
    }

    final alertType = AlertType.values.firstWhere(
      (t) => t.name.toLowerCase() == severity.toLowerCase(),
      orElse: () => AlertType.low,
    );

    if (!_cachedSettings!.notificationAlertTypes.contains(alertType)) {
      if (!_isHighRiskTime()) {
        return false;
      }
    }

    return distanceMeters <= _cachedSettings!.notificationAlertRadiusMeters;
  }

  bool shouldNotifyReport(String status, double distanceMeters) {
    if (_cachedSettings == null || !_cachedSettings!.notificationsEnabled) {
      return false;
    }

    final reportType = ReportType.values.firstWhere(
      (t) => t.name.toLowerCase() == status.toLowerCase(),
      orElse: () => ReportType.pending,
    );

    if (!_cachedSettings!.notificationReportTypes.contains(reportType)) {
      return false;
    }

    return distanceMeters <= _cachedSettings!.notificationReportRadiusMeters;
  }

  bool _isHighRiskTime() {
    if (_cachedSettings == null || !_cachedSettings!.timeBasedAlertsEnabled) {
      return false;
    }

    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final startTime = _parseTime(_cachedSettings!.highRiskStartTime);
    final endTime = _parseTime(_cachedSettings!.highRiskEndTime);

    return _isTimeBetween(currentTime, startTime, endTime);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isTimeBetween(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;

  bool get isLocationSharingEnabled =>
      _cachedSettings?.locationSharingEnabled ?? false;

  bool get isLocationHistoryEnabled =>
      _cachedSettings?.locationHistoryEnabled ?? true;

  bool get isDangerZonesEnabled => _cachedSettings?.dangerZonesEnabled ?? true;

  bool get isAnonymousReports => _cachedSettings?.anonymousReports ?? false;

  int get notificationAlertRadius =>
      _cachedSettings?.notificationAlertRadiusMeters ?? 1000;

  int get notificationReportRadius =>
      _cachedSettings?.notificationReportRadiusMeters ?? 500;

  void invalidateCache() {
    _cachedSettings = null;
    _lastFetch = null;
    log('Settings cache invalidated', name: 'SettingsManager');
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
