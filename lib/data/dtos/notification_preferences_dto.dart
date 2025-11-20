class NotificationPreferencesDTO {
  final bool pushEnabled;
  final bool smsEnabled;

  const NotificationPreferencesDTO({
    required this.pushEnabled,
    required this.smsEnabled,
  });

  factory NotificationPreferencesDTO.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDTO(
      pushEnabled: json['push_enabled'] ?? true,
      smsEnabled: json['sms_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'push_enabled': pushEnabled,
        'sms_enabled': smsEnabled,
      };
}

class UpdateDeviceInfoDTO {
  final String deviceFcmToken;
  final String deviceLanguage;

  const UpdateDeviceInfoDTO({
    required this.deviceFcmToken,
    required this.deviceLanguage,
  });

  Map<String, dynamic> toJson() => {
        'device_fcm_token': deviceFcmToken,
        'device_language': deviceLanguage,
      };
}
