import 'package:rpa/data/models/enums/risk_level.dart';
import 'package:rpa/data/models/route_waypoint.dart';
import 'package:rpa/data/models/route_incident.dart';

class SafeRoute {
  final String id;
  final double originLat;
  final double originLon;
  final double destinationLat;
  final double destinationLon;
  final List<RouteWaypoint> waypoints;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final double safetyScore;
  final RiskLevel riskLevel;
  final int incidentCount;
  final List<RouteIncident> incidents;
  final DateTime calculatedAt;

  const SafeRoute({
    required this.id,
    required this.originLat,
    required this.originLon,
    required this.destinationLat,
    required this.destinationLon,
    required this.waypoints,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.safetyScore,
    required this.riskLevel,
    required this.incidentCount,
    required this.incidents,
    required this.calculatedAt,
  });

  factory SafeRoute.fromJson(Map<String, dynamic> json) {
    return SafeRoute(
      id: json['id'] as String,
      originLat: (json['origin_lat'] as num).toDouble(),
      originLon: (json['origin_lon'] as num).toDouble(),
      destinationLat: (json['destination_lat'] as num).toDouble(),
      destinationLon: (json['destination_lon'] as num).toDouble(),
      waypoints: (json['waypoints'] as List)
          .map((w) => RouteWaypoint.fromJson(w as Map<String, dynamic>))
          .toList(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int,
      safetyScore: (json['safety_score'] as num).toDouble(),
      riskLevel: RiskLevel.fromValue(json['risk_level'] as String),
      incidentCount: json['incident_count'] as int,
      incidents: (json['incidents'] as List)
          .map((i) => RouteIncident.fromJson(i as Map<String, dynamic>))
          .toList(),
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin_lat': originLat,
      'origin_lon': originLon,
      'destination_lat': destinationLat,
      'destination_lon': destinationLon,
      'waypoints': waypoints.map((w) => w.toJson()).toList(),
      'distance_km': distanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'safety_score': safetyScore,
      'risk_level': riskLevel.value,
      'incident_count': incidentCount,
      'incidents': incidents.map((i) => i.toJson()).toList(),
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafeRoute &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          originLat == other.originLat &&
          originLon == other.originLon &&
          destinationLat == other.destinationLat &&
          destinationLon == other.destinationLon &&
          distanceKm == other.distanceKm &&
          estimatedDurationMinutes == other.estimatedDurationMinutes &&
          safetyScore == other.safetyScore &&
          riskLevel == other.riskLevel &&
          incidentCount == other.incidentCount &&
          calculatedAt == other.calculatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      originLat.hashCode ^
      originLon.hashCode ^
      destinationLat.hashCode ^
      destinationLon.hashCode ^
      distanceKm.hashCode ^
      estimatedDurationMinutes.hashCode ^
      safetyScore.hashCode ^
      riskLevel.hashCode ^
      incidentCount.hashCode ^
      calculatedAt.hashCode;
}
