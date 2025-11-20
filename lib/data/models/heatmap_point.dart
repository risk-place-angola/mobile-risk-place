class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double weight;
  final String incidentType;
  final int reportCount;

  const HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.weight,
    required this.incidentType,
    required this.reportCount,
  });

  factory HeatmapPoint.fromJson(Map<String, dynamic> json) {
    return HeatmapPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      incidentType: json['incident_type'] as String,
      reportCount: json['report_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'weight': weight,
      'incident_type': incidentType,
      'report_count': reportCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeatmapPoint &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          weight == other.weight &&
          incidentType == other.incidentType &&
          reportCount == other.reportCount;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      weight.hashCode ^
      incidentType.hashCode ^
      reportCount.hashCode;
}
