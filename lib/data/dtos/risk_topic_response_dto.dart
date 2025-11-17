/// DTO para resposta de Risk Topics da API
class RiskTopicResponseDTO {
  final String id;
  final String riskTypeId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RiskTopicResponseDTO({
    required this.id,
    required this.riskTypeId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskTopicResponseDTO.fromJson(Map<String, dynamic> json) {
    return RiskTopicResponseDTO(
      id: json['id'] as String,
      riskTypeId: json['risk_type_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'risk_type_id': riskTypeId,
        'name': name,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// DTO para lista de Risk Topics
class ListRiskTopicsResponseDTO {
  final List<RiskTopicResponseDTO> data;

  const ListRiskTopicsResponseDTO({required this.data});

  factory ListRiskTopicsResponseDTO.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return ListRiskTopicsResponseDTO(
      data: dataList
          .map((item) => RiskTopicResponseDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
      };
}
