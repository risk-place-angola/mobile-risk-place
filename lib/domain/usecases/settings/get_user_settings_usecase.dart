import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/domain/repositories/settings_repository.dart';
import 'package:rpa/data/repositories/settings_repository_impl.dart';

class GetUserSettingsUseCase {
  final ISettingsRepository repository;

  GetUserSettingsUseCase({required this.repository});

  Future<UserSettings> execute() async {
    log('[GetUserSettingsUseCase] Fetching user settings');
    try {
      final settings = await repository.getSettings();
      log('[GetUserSettingsUseCase] Settings fetched successfully');
      return settings;
    } catch (e) {
      log('[GetUserSettingsUseCase] Error fetching settings: $e');
      rethrow;
    }
  }
}

final getUserSettingsUseCaseProvider = Provider<GetUserSettingsUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetUserSettingsUseCase(repository: repository);
});
