/// DTO para request de criação de Alert
class CreateAlertRequestDTO {
  final String riskTypeId;
  final String riskTopicId;
  final String message;
  final double latitude;
  final double longitude;
  final double radius;
  final String severity; // low, medium, high

  const CreateAlertRequestDTO({
    required this.riskTypeId,
    required this.riskTopicId,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'risk_type_id': riskTypeId,
        'risk_topic_id': riskTopicId,
        'message': message,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'severity': severity,
      };
}

/// DTO para resposta de criação de Alert
class AlertResponseDTO {
  final String id;
  final String userId;
  final String riskTypeId;
  final String riskTopicId;
  final String message;
  final double latitude;
  final double longitude;
  final double radius;
  final String severity;
  final String status; // active, resolved
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const AlertResponseDTO({
    required this.id,
    required this.userId,
    required this.riskTypeId,
    required this.riskTopicId,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.severity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory AlertResponseDTO.fromJson(Map<String, dynamic> json) {
    return AlertResponseDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      riskTypeId: json['risk_type_id'] as String,
      riskTopicId: json['risk_topic_id'] as String,
      message: json['message'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      severity: json['severity'] as String,
      status: json['status'] as String,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.tryParse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'risk_type_id': riskTypeId,
        'risk_topic_id': riskTopicId,
        'message': message,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'severity': severity,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };
}

/// DTO para resposta ao criar alert (com mensagem adicional)
class CreateAlertResponseDTO {
  final AlertResponseDTO data;
  final String message;

  const CreateAlertResponseDTO({
    required this.data,
    required this.message,
  });

  factory CreateAlertResponseDTO.fromJson(Map<String, dynamic> json) {
    return CreateAlertResponseDTO(
      data: AlertResponseDTO.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.toJson(),
        'message': message,
      };
}
