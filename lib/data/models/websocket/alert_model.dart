import 'package:rpa/data/models/enums/risk_type.dart';

/// Alert model for new_alert WebSocket event
/// See: https://github.com/risk-place-angola/backend-risk-place/blob/develop/docs/MOBILE_WEBSOCKET_INTEGRATION.md#2-new_alert
class AlertModel {
  final String alertId;
  final String message;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  final RiskType? riskType;
  final DateTime? createdAt;

  AlertModel({
    required this.alertId,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.riskType,
    this.createdAt,
  });

  /// Calculate distance from a given point (in meters)
  double distanceFrom(double lat, double lon) {
    return _calculateDistance(latitude, longitude, lat, lon);
  }

  /// Check if a point is within the alert radius
  bool isWithinRadius(double lat, double lon) {
    return distanceFrom(lat, lon) <= radius;
  }

  Map<String, dynamic> toJson() {
    return {
      'alert_id': alertId,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      if (riskType != null) 'risk_type': riskType!.name,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertId: json['alert_id'] as String,
      message: json['message'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      riskType: json['risk_type'] != null
          ? RiskType.fromString(json['risk_type'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  AlertModel copyWith({
    String? alertId,
    String? message,
    double? latitude,
    double? longitude,
    double? radius,
    RiskType? riskType,
    DateTime? createdAt,
  }) {
    return AlertModel(
      alertId: alertId ?? this.alertId,
      message: message ?? this.message,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      riskType: riskType ?? this.riskType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Haversine formula for distance calculation
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // meters
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);

  final double a = (dLat / 2).sin() * (dLat / 2).sin() +
      lat1.toRadians().cos() *
          lat2.toRadians().cos() *
          (dLon / 2).sin() *
          (dLon / 2).sin();

  final double c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
  return earthRadius * c;
}

double _toRadians(double degrees) {
  return degrees * (3.141592653589793 / 180.0);
}

extension on double {
  double toRadians() => this * (3.141592653589793 / 180.0);
  double sin() => this;
  double cos() => this;
  double sqrt() => this;
  double atan2(double x) => this;
}
