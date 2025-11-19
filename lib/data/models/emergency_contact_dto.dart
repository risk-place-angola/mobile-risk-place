import 'package:rpa/domain/entities/emergency_contact.dart' as domain;

class EmergencyContactDto {
  final String? id;
  final String? userId;
  final String name;
  final String phone;
  final String relation;
  final bool isPriority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmergencyContactDto({
    this.id,
    this.userId,
    required this.name,
    required this.phone,
    required this.relation,
    required this.isPriority,
    this.createdAt,
    this.updatedAt,
  });

  factory EmergencyContactDto.fromJson(Map<String, dynamic> json) {
    return EmergencyContactDto(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relation: json['relation'] as String,
      isPriority: json['is_priority'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'phone': phone,
      'relation': relation,
      'is_priority': isPriority,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  domain.EmergencyContact toEntity() {
    return domain.EmergencyContact(
      id: id ?? '',
      userId: userId ?? '',
      name: name,
      phone: phone,
      relation: domain.ContactRelation.fromString(relation),
      isPriority: isPriority,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory EmergencyContactDto.fromEntity(domain.EmergencyContact entity) {
    return EmergencyContactDto(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      phone: entity.phone,
      relation: entity.relation.name,
      isPriority: entity.isPriority,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
