class NearbyReportDTO {
  final String id;
  final String userId;
  final String riskTypeId;
  final String? riskTypeName;
  final String? riskTypeIconUrl;
  final String riskTopicId;
  final String? riskTopicName;
  final String? riskTopicIconUrl;
  final String status;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double distance;
  final String province;
  final String municipality;
  final String neighborhood;
  final String address;
  final String? reviewedBy;
  final int upvotes;
  final int downvotes;
  final int netVotes;
  final String? userVote;
  final bool verified;
  final DateTime? verifiedAt;
  final int verificationCount;
  final int rejectionCount;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const NearbyReportDTO({
    required this.id,
    required this.userId,
    required this.riskTypeId,
    this.riskTypeName,
    this.riskTypeIconUrl,
    required this.riskTopicId,
    this.riskTopicName,
    this.riskTopicIconUrl,
    required this.status,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.province,
    required this.municipality,
    required this.neighborhood,
    required this.address,
    this.reviewedBy,
    this.upvotes = 0,
    this.downvotes = 0,
    this.netVotes = 0,
    this.userVote,
    this.verified = false,
    this.verifiedAt,
    this.verificationCount = 0,
    this.rejectionCount = 0,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory NearbyReportDTO.fromJson(Map<String, dynamic> json) {
    return NearbyReportDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      riskTypeId: json['risk_type_id'] as String,
      riskTypeName: json['risk_type_name'] as String?,
      riskTypeIconUrl: json['risk_type_icon_url'] as String?,
      riskTopicId: json['risk_topic_id'] as String,
      riskTopicName: json['risk_topic_name'] as String?,
      riskTopicIconUrl: json['risk_topic_icon_url'] as String?,
      status: json['status'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      province: json['province'] as String? ?? '',
      municipality: json['municipality'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      address: json['address'] as String? ?? '',
      reviewedBy: json['reviewed_by'] as String?,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      netVotes: json['net_votes'] as int? ?? 0,
      userVote: json['user_vote'] as String?,
      verified: json['verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      verificationCount: json['verification_count'] as int? ?? 0,
      rejectionCount: json['rejection_count'] as int? ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'risk_type_id': riskTypeId,
        'risk_type_name': riskTypeName,
        'risk_type_icon_url': riskTypeIconUrl,
        'risk_topic_id': riskTopicId,
        'risk_topic_name': riskTopicName,
        'risk_topic_icon_url': riskTopicIconUrl,
        'status': status,
        'description': description,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'distance': distance,
        'province': province,
        'municipality': municipality,
        'neighborhood': neighborhood,
        'address': address,
        'reviewed_by': reviewedBy,
        'upvotes': upvotes,
        'downvotes': downvotes,
        'net_votes': netVotes,
        'user_vote': userVote,
        'verified': verified,
        'verified_at': verifiedAt?.toIso8601String(),
        'verification_count': verificationCount,
        'rejection_count': rejectionCount,
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };
}

/// DTO para resposta de listagem de reports nearby
/// Backend retorna apenas array de data, sem objeto meta
class ListNearbyReportsResponseDTO {
  final List<NearbyReportDTO> data;

  const ListNearbyReportsResponseDTO({
    required this.data,
  });

  factory ListNearbyReportsResponseDTO.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return ListNearbyReportsResponseDTO(
      data: dataList
          .map((item) => NearbyReportDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
      };
}
