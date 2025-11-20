class UpdateReportLocationRequestDTO {
  final double latitude;
  final double longitude;
  final String? address;
  final String? neighborhood;
  final String? municipality;
  final String? province;

  const UpdateReportLocationRequestDTO({
    required this.latitude,
    required this.longitude,
    this.address,
    this.neighborhood,
    this.municipality,
    this.province,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (neighborhood != null && neighborhood!.isNotEmpty)
        'neighborhood': neighborhood,
      if (municipality != null && municipality!.isNotEmpty)
        'municipality': municipality,
      if (province != null && province!.isNotEmpty) 'province': province,
    };
  }
}

/// Response DTO for update report location
class UpdateReportLocationResponseDTO {
  final String id;
  final String message;
  final DateTime updatedAt;

  const UpdateReportLocationResponseDTO({
    required this.id,
    required this.message,
    required this.updatedAt,
  });

  /// Create from JSON response
  factory UpdateReportLocationResponseDTO.fromJson(Map<String, dynamic> json) {
    return UpdateReportLocationResponseDTO(
      id: json['id'] as String,
      message: json['message'] as String? ?? 'Location updated successfully',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
