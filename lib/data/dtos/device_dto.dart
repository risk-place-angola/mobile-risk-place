import 'dart:io';

class DeviceRegisterRequestDTO {
  final String deviceId;
  final String? fcmToken;
  final String platform;
  final String? model;
  final String language;
  final double? latitude;
  final double? longitude;
  final int alertRadiusMeters;

  DeviceRegisterRequestDTO({
    required this.deviceId,
    this.fcmToken,
    String? platform,
    this.model,
    this.language = 'pt',
    this.latitude,
    this.longitude,
    this.alertRadiusMeters = 1000,
  }) : platform = platform ?? (Platform.isIOS ? 'ios' : 'android');

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        if (fcmToken != null) 'fcm_token': fcmToken,
        'platform': platform,
        if (model != null) 'model': model,
        'language': language,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'alert_radius_meters': alertRadiusMeters,
      };
}

class DeviceRegisterResponseDTO {
  final String deviceId;
  final String? fcmToken;
  final String? message;

  DeviceRegisterResponseDTO({
    required this.deviceId,
    this.fcmToken,
    this.message,
  });

  factory DeviceRegisterResponseDTO.fromJson(Map<String, dynamic> json) {
    return DeviceRegisterResponseDTO(
      deviceId: json['device_id'] as String,
      fcmToken: json['fcm_token'] as String?,
      message: json['message'] as String?,
    );
  }
}

class UpdateDeviceLocationDTO {
  final String deviceId;
  final double latitude;
  final double longitude;

  UpdateDeviceLocationDTO({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'latitude': latitude,
        'longitude': longitude,
      };
}
