import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/models/user_settings_dto.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final IHttpClient _httpClient;

  SettingsRepositoryImpl({required IHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<UserSettings> getSettings() async {
    log('[SettingsRepository] Fetching user settings');
    try {
      final response = await _httpClient.get('/users/me/settings');

      if (response.statusCode == 404 || response.statusCode == 500) {
        // Settings not found or server error, try to create default settings
        log('[SettingsRepository] Settings not found (${response.statusCode}), attempting to create defaults');
        return await _createDefaultSettings();
      }

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch settings',
          statusCode: response.statusCode,
        );
      }

      final settingsDto =
          UserSettingsDto.fromJson(response.data as Map<String, dynamic>);
      log('[SettingsRepository] Settings fetched successfully');
      return settingsDto.toEntity();
    } catch (e) {
      log('[SettingsRepository] Error fetching settings: $e');
      // If network error or other exception, try to create default settings
      if (e is ServerException && (e.statusCode == 404 || e.statusCode == 500)) {
        try {
          return await _createDefaultSettings();
        } catch (createError) {
          log('[SettingsRepository] Failed to create default settings: $createError');
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<UserSettings> _createDefaultSettings() async {
    log('[SettingsRepository] Creating default settings');
    try {
      final defaultSettings = {
        'notifications_enabled': true,
        'notification_alert_types': ['high', 'critical'],
        'notification_alert_radius_mins': 1000,
        'notification_report_types': ['verified'],
        'notification_report_radius_mins': 500,
        'location_sharing_enabled': false,
        'location_history_enabled': true,
        'profile_visibility': 'public',
        'anonymous_reports': false,
        'show_online_status': true,
        'auto_alerts_enabled': false,
        'danger_zones_enabled': true,
        'time_based_alerts_enabled': false,
        'high_risk_start_time': '22:00',
        'high_risk_end_time': '06:00',
        'night_mode_enabled': false,
        'night_mode_start_time': '22:00',
        'night_mode_end_time': '06:00',
      };

      final response = await _httpClient.post(
        '/users/me/settings',
        data: defaultSettings,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Failed to create default settings',
          statusCode: response.statusCode,
        );
      }

      final settingsDto =
          UserSettingsDto.fromJson(response.data as Map<String, dynamic>);
      log('[SettingsRepository] Default settings created successfully');
      return settingsDto.toEntity();
    } catch (e) {
      log('[SettingsRepository] Error creating default settings: $e');
      rethrow;
    }
  }

  @override
  Future<UserSettings> updateSettings(Map<String, dynamic> updates) async {
    log('[SettingsRepository] Updating settings');
    try {
      final body = _convertToSnakeCase(updates);

      final response = await _httpClient.put(
        '/users/me/settings',
        data: body,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to update settings',
          statusCode: response.statusCode,
        );
      }

      final settingsDto =
          UserSettingsDto.fromJson(response.data as Map<String, dynamic>);
      log('[SettingsRepository] Settings updated successfully');
      return settingsDto.toEntity();
    } catch (e) {
      log('[SettingsRepository] Error updating settings: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _convertToSnakeCase(Map<String, dynamic> updates) {
    final Map<String, dynamic> snakeCaseMap = {};

    // Field name mapping: camelCase -> backend_snake_case
    const fieldMapping = {
      'notificationAlertRadiusMeters': 'notification_alert_radius_mins',
      'notificationReportRadiusMeters': 'notification_report_radius_mins',
    };

    updates.forEach((key, value) {
      // Use explicit mapping if exists, otherwise convert to snake_case
      final snakeKey = fieldMapping[key] ?? _toSnakeCase(key);

      if (value is List) {
        if (value.isNotEmpty && value.first is Enum) {
          snakeCaseMap[snakeKey] = value.map((e) => (e as Enum).name).toList();
        } else {
          snakeCaseMap[snakeKey] = value;
        }
      } else if (value is Enum) {
        snakeCaseMap[snakeKey] = value.name;
      } else {
        snakeCaseMap[snakeKey] = value;
      }
    });

    return snakeCaseMap;
  }

  String _toSnakeCase(String camelCase) {
    return camelCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return SettingsRepositoryImpl(httpClient: httpClient);
});
