class CreateReportRequestDTO {
  final String userId;
  final String riskTopicId;
  final String riskTypeId;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String municipality;
  final String neighborhood;
  final String province;
  final String imageUrl;

  const CreateReportRequestDTO({
    required this.userId,
    required this.riskTopicId,
    required this.riskTypeId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.municipality,
    required this.neighborhood,
    required this.province,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'risk_topic_id': riskTopicId,
        'risk_type_id': riskTypeId,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'municipality': municipality,
        'neighborhood': neighborhood,
        'province': province,
        'image_url': imageUrl,
      };
}

class ReportResponseDTO {
  final String id;
  final String userId;
  final String riskTopicId;
  final String riskTypeId;
  final String status;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;

  final String address;
  final String municipality;
  final String neighborhood;
  final String province;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String reviewedBy;

  const ReportResponseDTO({
    required this.id,
    required this.userId,
    required this.riskTopicId,
    required this.riskTypeId,
    required this.status,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.municipality,
    required this.neighborhood,
    required this.province,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    required this.reviewedBy,
  });

  factory ReportResponseDTO.fromJson(Map<String, dynamic> json) {
    return ReportResponseDTO(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      riskTopicId: json['risk_topic_id'] ?? '',
      riskTypeId: json['risk_type_id'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] ?? '',
      municipality: json['municipality'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      province: json['province'] ?? '',
      reviewedBy: json['reviewed_by'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'])
          : null,
    );
  }
}
