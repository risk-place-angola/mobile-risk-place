enum AlertStatus {
  active,
  resolved,
  expired;

  String get displayName {
    switch (this) {
      case AlertStatus.active:
        return 'Ativo';
      case AlertStatus.resolved:
        return 'Resolvido';
      case AlertStatus.expired:
        return 'Expirado';
    }
  }

  static AlertStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return AlertStatus.active;
      case 'resolved':
        return AlertStatus.resolved;
      case 'expired':
        return AlertStatus.expired;
      default:
        return AlertStatus.expired;
    }
  }
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Baixo';
      case AlertSeverity.medium:
        return 'Médio';
      case AlertSeverity.high:
        return 'Alto';
      case AlertSeverity.critical:
        return 'Crítico';
    }
  }

  static AlertSeverity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return AlertSeverity.low;
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
        return AlertSeverity.high;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.medium;
    }
  }
}

class UserAlert {
  final String id;
  final String riskTypeName;
  final String riskTopicName;
  final String message;
  final double latitude;
  final double longitude;
  final String province;
  final String municipality;
  final String? neighborhood;
  final String? address;
  final int radiusMeters;
  final AlertStatus status;
  final AlertSeverity severity;
  final bool isSubscribed;
  final int? subscribers;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const UserAlert({
    required this.id,
    required this.riskTypeName,
    required this.riskTopicName,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.municipality,
    this.neighborhood,
    this.address,
    required this.radiusMeters,
    required this.status,
    required this.severity,
    required this.isSubscribed,
    this.subscribers,
    required this.createdAt,
    this.expiresAt,
  });

  UserAlert copyWith({
    String? id,
    String? riskTypeName,
    String? riskTopicName,
    String? message,
    double? latitude,
    double? longitude,
    String? province,
    String? municipality,
    String? neighborhood,
    String? address,
    int? radiusMeters,
    AlertStatus? status,
    AlertSeverity? severity,
    bool? isSubscribed,
    int? subscribers,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return UserAlert(
      id: id ?? this.id,
      riskTypeName: riskTypeName ?? this.riskTypeName,
      riskTopicName: riskTopicName ?? this.riskTopicName,
      message: message ?? this.message,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      province: province ?? this.province,
      municipality: municipality ?? this.municipality,
      neighborhood: neighborhood ?? this.neighborhood,
      address: address ?? this.address,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscribers: subscribers ?? this.subscribers,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
