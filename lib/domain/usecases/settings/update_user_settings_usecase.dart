import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/domain/repositories/settings_repository.dart';
import 'package:rpa/data/repositories/settings_repository_impl.dart';

class UpdateUserSettingsUseCase {
  final ISettingsRepository repository;

  UpdateUserSettingsUseCase({required this.repository});

  Future<UserSettings> execute(Map<String, dynamic> updates) async {
    log('[UpdateUserSettingsUseCase] Updating settings with: $updates');

    if (updates.containsKey('notificationAlertRadiusMeters')) {
      final radius = updates['notificationAlertRadiusMeters'] as int;
      if (radius < 100 || radius > 10000) {
        throw Exception(
            'Notification alert radius must be between 100 and 10000 meters');
      }
    }

    if (updates.containsKey('notificationReportRadiusMeters')) {
      final radius = updates['notificationReportRadiusMeters'] as int;
      if (radius < 100 || radius > 10000) {
        throw Exception(
            'Notification report radius must be between 100 and 10000 meters');
      }
    }

    if (updates.containsKey('highRiskStartTime')) {
      final time = updates['highRiskStartTime'] as String;
      if (!_isValidTimeFormat(time)) {
        throw Exception('Invalid high_risk_start_time format, expected HH:MM');
      }
    }

    if (updates.containsKey('highRiskEndTime')) {
      final time = updates['highRiskEndTime'] as String;
      if (!_isValidTimeFormat(time)) {
        throw Exception('Invalid high_risk_end_time format, expected HH:MM');
      }
    }

    if (updates.containsKey('nightModeStartTime')) {
      final time = updates['nightModeStartTime'] as String;
      if (!_isValidTimeFormat(time)) {
        throw Exception('Invalid night_mode_start_time format, expected HH:MM');
      }
    }

    if (updates.containsKey('nightModeEndTime')) {
      final time = updates['nightModeEndTime'] as String;
      if (!_isValidTimeFormat(time)) {
        throw Exception('Invalid night_mode_end_time format, expected HH:MM');
      }
    }

    try {
      final settings = await repository.updateSettings(updates);
      log('[UpdateUserSettingsUseCase] Settings updated successfully');
      return settings;
    } catch (e) {
      log('[UpdateUserSettingsUseCase] Error updating settings: $e');
      rethrow;
    }
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return regex.hasMatch(time);
  }
}

final updateUserSettingsUseCaseProvider =
    Provider<UpdateUserSettingsUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateUserSettingsUseCase(repository: repository);
});
