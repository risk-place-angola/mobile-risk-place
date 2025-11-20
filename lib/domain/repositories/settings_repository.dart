import 'package:rpa/domain/entities/user_settings.dart';

abstract class ISettingsRepository {
  Future<UserSettings> getSettings();
  Future<UserSettings> updateSettings(Map<String, dynamic> updates);
}
