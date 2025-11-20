import 'package:rpa/domain/entities/user_alert.dart';

class UserAlertDto {
  final String? id;
  final String? riskTypeName;
  final String? riskTopicName;
  final String message;
  final double latitude;
  final double longitude;
  final String province;
  final String municipality;
  final String? neighborhood;
  final String? address;
  final int radiusMeters;
  final String? status;
  final String severity;
  final bool? isSubscribed;
  final int? subscribers;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  UserAlertDto({
    this.id,
    this.riskTypeName,
    this.riskTopicName,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.municipality,
    this.neighborhood,
    this.address,
    required this.radiusMeters,
    this.status,
    required this.severity,
    this.isSubscribed,
    this.subscribers,
    this.createdAt,
    this.expiresAt,
  });

  factory UserAlertDto.fromJson(Map<String, dynamic> json) {
    return UserAlertDto(
      id: json['id'] as String?,
      riskTypeName: json['risk_type_name'] as String?,
      riskTopicName: json['risk_topic_name'] as String?,
      message: json['message'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      province: json['province'] as String,
      municipality: json['municipality'] as String,
      neighborhood: json['neighborhood'] as String?,
      address: json['address'] as String?,
      radiusMeters: json['radius_meters'] as int,
      status: json['status'] as String?,
      severity: json['severity'] as String,
      isSubscribed: json['is_subscribed'] as bool?,
      subscribers: json['subscribers'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'message': message,
      'severity': severity,
      'radius_meters': radiusMeters,
    };
  }

  UserAlert toEntity() {
    return UserAlert(
      id: id ?? '',
      riskTypeName: riskTypeName ?? '',
      riskTopicName: riskTopicName ?? '',
      message: message,
      latitude: latitude,
      longitude: longitude,
      province: province,
      municipality: municipality,
      neighborhood: neighborhood,
      address: address,
      radiusMeters: radiusMeters,
      status:
          status != null ? AlertStatus.fromString(status!) : AlertStatus.active,
      severity: AlertSeverity.fromString(severity),
      isSubscribed: isSubscribed ?? false,
      subscribers: subscribers,
      createdAt: createdAt ?? DateTime.now(),
      expiresAt: expiresAt,
    );
  }

  factory UserAlertDto.fromEntity(UserAlert entity) {
    return UserAlertDto(
      id: entity.id,
      riskTypeName: entity.riskTypeName,
      riskTopicName: entity.riskTopicName,
      message: entity.message,
      latitude: entity.latitude,
      longitude: entity.longitude,
      province: entity.province,
      municipality: entity.municipality,
      neighborhood: entity.neighborhood,
      address: entity.address,
      radiusMeters: entity.radiusMeters,
      status: entity.status.name,
      severity: entity.severity.name,
      isSubscribed: entity.isSubscribed,
      subscribers: entity.subscribers,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
    );
  }
}
