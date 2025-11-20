class RiskTypeDTO {
  final String id;
  final String name;
  final String description;
  final int defaultRadius;
  final String? iconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RiskTypeDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultRadius,
    this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskTypeDTO.fromJson(Map<String, dynamic> json) {
    return RiskTypeDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      defaultRadius: json['default_radius'] as int? ?? 1000,
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'default_radius': defaultRadius,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// DTO para lista de Risk Types
class ListRiskTypesResponseDTO {
  final List<RiskTypeDTO> data;

  const ListRiskTypesResponseDTO({
    required this.data,
  });

  factory ListRiskTypesResponseDTO.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return ListRiskTypesResponseDTO(
      data: dataList
          .map((item) => RiskTypeDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
      };
}
