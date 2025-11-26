import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/data/services/settings.service.dart';

final settingsNotifierProvider = FutureProvider<UserSettings>((ref) async {
  final settingsService = ref.watch(settingsServiceProvider);
  return await settingsService.getSettings();
});

final currentReportRadiusProvider = Provider<int>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);

  return settingsAsync.when(
    data: (settings) => settings.notificationReportRadiusMeters,
    loading: () => 5000,
    error: (_, __) => 5000,
  );
});

class SettingsHelper {
  static Future<void> updateReportRadius(
    WidgetRef ref,
    int newRadius,
  ) async {
    try {
      log('[SettingsHelper] Updating report radius to $newRadius');
      final settingsService = ref.read(settingsServiceProvider);
      await settingsService.updateSettings({
        'notificationReportRadiusMeters': newRadius,
      });

      ref.invalidate(settingsNotifierProvider);
      log('[SettingsHelper] Report radius updated successfully');
    } catch (error) {
      log('[SettingsHelper] Error updating report radius: $error');
      rethrow;
    }
  }
}
