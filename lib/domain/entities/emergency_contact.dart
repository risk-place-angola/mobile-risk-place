enum ContactRelation {
  family,
  friend,
  colleague,
  neighbor,
  other;

  /// Get localized display name
  /// Note: This is a fallback. Use getLocalizedName(context) instead when context is available.
  String get displayName {
    switch (this) {
      case ContactRelation.family:
        return 'Família';
      case ContactRelation.friend:
        return 'Amigo';
      case ContactRelation.colleague:
        return 'Colega';
      case ContactRelation.neighbor:
        return 'Vizinho';
      case ContactRelation.other:
        return 'Outro';
    }
  }

  static ContactRelation fromString(String value) {
    switch (value.toLowerCase()) {
      case 'family':
        return ContactRelation.family;
      case 'friend':
        return ContactRelation.friend;
      case 'colleague':
        return ContactRelation.colleague;
      case 'neighbor':
        return ContactRelation.neighbor;
      case 'other':
        return ContactRelation.other;
      default:
        return ContactRelation.other;
    }
  }
  
  /// Convert enum to backend string value
  String toBackendString() {
    return name; // Returns 'family', 'friend', 'colleague', 'neighbor', 'other'
  }
}

class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final ContactRelation relation;
  final bool isPriority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.relation,
    required this.isPriority,
    required this.createdAt,
    required this.updatedAt,
  });

  EmergencyContact copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    ContactRelation? relation,
    bool? isPriority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      isPriority: isPriority ?? this.isPriority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Helper function to get localized contact relation name
String getLocalizedRelationName(ContactRelation relation, dynamic l10n) {
  switch (relation) {
    case ContactRelation.family:
      return l10n?.relationFamily ?? 'Família';
    case ContactRelation.friend:
      return l10n?.relationFriend ?? 'Amigo';
    case ContactRelation.colleague:
      return l10n?.relationColleague ?? 'Colega';
    case ContactRelation.neighbor:
      return l10n?.relationNeighbor ?? 'Vizinho';
    case ContactRelation.other:
      return l10n?.relationOther ?? 'Outro';
  }
}
