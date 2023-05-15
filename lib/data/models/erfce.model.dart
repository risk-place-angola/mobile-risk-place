class ERFCE {
  String? id;
  Map<String, String>? location;

  Type? type;
  DateTime? createdAt;

  ERFCE({
    this.id,
    this.location,
    this.type,
    this.createdAt,
  });

  factory ERFCE.fromJson(var json) => ERFCE(
        id: json['id'] != null ? json['id'] : null,
        location: json['location'] != null ? json['location'] : null,
        type: json['type'] != null ? json['type'] : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'location': location,
        'type': type,
        'created_at': createdAt,
      };
}

enum Type { Policia, Bombeiro, Medico, Outro }
