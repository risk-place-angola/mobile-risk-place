class Warning {
  String? id, reportedBy, description;
  DateTime? createdAt;
  Map<String, String>? location;
  bool? isVictim;
  dynamic additionalData;

  Warning({
    this.id,
    this.reportedBy,
    this.description,
    this.createdAt,
    this.location,
    this.isVictim,
    this.additionalData,
  });

  factory Warning.fromJson(var json) => Warning(
        id: json['id'] != null ? json['id'] : null,
        reportedBy: json['reported_by'] != null ? json['reported_by'] : null,
        description: json['description'] != null ? json['description'] : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        location: json['location'] != null ? json['location'] : null,
        isVictim: json['is_victim'] != null ? json['is_victim'] : null,
        additionalData:
            json['additional_data'] != null ? json['additional_data'] : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reported_by': reportedBy,
        'description': description,
        'created_at': createdAt!.toIso8601String(),
        'location': location,
        'is_victim': isVictim,
        'additional_data': additionalData,
      };
}
