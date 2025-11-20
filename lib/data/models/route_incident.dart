class RouteIncident {
  final String reportId;
  final String riskType;
  final String riskTopic;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final DateTime createdAt;
  final int daysAgo;
  final double weightFactor;

  const RouteIncident({
    required this.reportId,
    required this.riskType,
    required this.riskTopic,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.createdAt,
    required this.daysAgo,
    required this.weightFactor,
  });

  factory RouteIncident.fromJson(Map<String, dynamic> json) {
    return RouteIncident(
      reportId: json['report_id'] as String,
      riskType: json['risk_type'] as String,
      riskTopic: json['risk_topic'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      daysAgo: json['days_ago'] as int,
      weightFactor: (json['weight_factor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'risk_type': riskType,
      'risk_topic': riskTopic,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'created_at': createdAt.toIso8601String(),
      'days_ago': daysAgo,
      'weight_factor': weightFactor,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteIncident &&
          runtimeType == other.runtimeType &&
          reportId == other.reportId &&
          riskType == other.riskType &&
          riskTopic == other.riskTopic &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          distanceKm == other.distanceKm &&
          createdAt == other.createdAt &&
          daysAgo == other.daysAgo &&
          weightFactor == other.weightFactor;

  @override
  int get hashCode =>
      reportId.hashCode ^
      riskType.hashCode ^
      riskTopic.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      distanceKm.hashCode ^
      createdAt.hashCode ^
      daysAgo.hashCode ^
      weightFactor.hashCode;
}
