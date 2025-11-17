/// DTO para informações aninhadas de Risk Type na resposta de reports
class RiskTypeInfoDTO {
  final String id;
  final String name;
  final String description;

  const RiskTypeInfoDTO({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RiskTypeInfoDTO.fromJson(Map<String, dynamic> json) {
    return RiskTypeInfoDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}

/// DTO para informações aninhadas de Risk Topic na resposta de reports
class RiskTopicInfoDTO {
  final String id;
  final String name;
  final String description;

  const RiskTopicInfoDTO({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RiskTopicInfoDTO.fromJson(Map<String, dynamic> json) {
    return RiskTopicInfoDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}

/// DTO para um report individual na listagem nearby
class NearbyReportDTO {
  final String id;
  final String userId;
  final RiskTypeInfoDTO riskType;
  final RiskTopicInfoDTO riskTopic;
  final String status;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double distance; // Distância em metros
  final String province;
  final String municipality;
  final String neighborhood;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const NearbyReportDTO({
    required this.id,
    required this.userId,
    required this.riskType,
    required this.riskTopic,
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
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory NearbyReportDTO.fromJson(Map<String, dynamic> json) {
    return NearbyReportDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      riskType: RiskTypeInfoDTO.fromJson(json['risk_type'] as Map<String, dynamic>),
      riskTopic: RiskTopicInfoDTO.fromJson(json['risk_topic'] as Map<String, dynamic>),
      status: json['status'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      province: json['province'] as String? ?? '',
      municipality: json['municipality'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      address: json['address'] as String? ?? '',
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
        'risk_type': riskType.toJson(),
        'risk_topic': riskTopic.toJson(),
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
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };
}

/// DTO para metadata de paginação
class PaginationMetaDTO {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const PaginationMetaDTO({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginationMetaDTO.fromJson(Map<String, dynamic> json) {
    return PaginationMetaDTO(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['has_more'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'limit': limit,
        'offset': offset,
        'has_more': hasMore,
      };
}

/// DTO para resposta de listagem de reports nearby
class ListNearbyReportsResponseDTO {
  final List<NearbyReportDTO> data;
  final PaginationMetaDTO meta;

  const ListNearbyReportsResponseDTO({
    required this.data,
    required this.meta,
  });

  factory ListNearbyReportsResponseDTO.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return ListNearbyReportsResponseDTO(
      data: dataList
          .map((item) => NearbyReportDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMetaDTO.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
        'meta': meta.toJson(),
      };
}
