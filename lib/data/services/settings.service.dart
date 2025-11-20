import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/domain/usecases/settings/get_user_settings_usecase.dart';
import 'package:rpa/domain/usecases/settings/update_user_settings_usecase.dart';

class SettingsService {
  final GetUserSettingsUseCase getUserSettingsUseCase;
  final UpdateUserSettingsUseCase updateUserSettingsUseCase;

  UserSettings? _cachedSettings;

  SettingsService({
    required this.getUserSettingsUseCase,
    required this.updateUserSettingsUseCase,
  });

  Future<UserSettings> getSettings({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSettings != null) {
      log('[SettingsService] Returning cached settings');
      return _cachedSettings!;
    }

    log('[SettingsService] Fetching settings from repository');
    _cachedSettings = await getUserSettingsUseCase.execute();
    return _cachedSettings!;
  }

  Future<UserSettings> updateSettings(Map<String, dynamic> updates) async {
    log('[SettingsService] Updating settings: $updates');
    _cachedSettings = await updateUserSettingsUseCase.execute(updates);
    return _cachedSettings!;
  }

  void clearCache() {
    log('[SettingsService] Clearing settings cache');
    _cachedSettings = null;
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(
    getUserSettingsUseCase: ref.watch(getUserSettingsUseCaseProvider),
    updateUserSettingsUseCase: ref.watch(updateUserSettingsUseCaseProvider),
  );
});
