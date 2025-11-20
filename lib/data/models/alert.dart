class Alert {
  final String userId;
  final String riskTopicId;
  final String riskTypeId;
  final String severity;
  final String message;
  final double radius;
  final double latitude;
  final double longitude;

  const Alert({
    required this.userId,
    required this.riskTopicId,
    required this.riskTypeId,
    required this.severity,
    required this.message,
    required this.radius,
    required this.latitude,
    required this.longitude,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      userId: json['user_id'] ?? '',
      riskTopicId: json['risk_topic_id'] ?? '',
      riskTypeId: json['risk_type_id'] ?? '',
      severity: json['severity'] ?? '',
      message: json['message'] ?? '',
      radius: (json['radius'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'risk_topic_id': riskTopicId,
        'risk_type_id': riskTypeId,
        'severity': severity,
        'message': message,
        'radius': radius,
        'latitude': latitude,
        'longitude': longitude,
      };
}
