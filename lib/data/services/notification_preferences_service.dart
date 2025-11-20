import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/data/dtos/notification_preferences_dto.dart';

class NotificationPreferencesService {
  final HttpClient _httpClient;

  NotificationPreferencesService(this._httpClient);

  Future<NotificationPreferencesDTO> getPreferences() async {
    final response = await _httpClient.get(
      '/api/v1/users/me/notifications/preferences',
    );
    return NotificationPreferencesDTO.fromJson(response.data);
  }

  Future<void> updatePreferences({
    required bool pushEnabled,
    required bool smsEnabled,
  }) async {
    await _httpClient.put(
      '/api/v1/users/me/notifications/preferences',
      data: {
        'push_enabled': pushEnabled,
        'sms_enabled': smsEnabled,
      },
    );
  }

  Future<void> updateDeviceInfo({
    required String fcmToken,
    required String language,
  }) async {
    await _httpClient.put(
      '/api/v1/users/me/device',
      data: {
        'device_fcm_token': fcmToken,
        'device_language': language,
      },
    );
  }
}
