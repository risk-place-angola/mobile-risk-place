import 'dart:math' as math;
import 'package:flutter/material.dart';

enum DangerZoneRiskLevel {
  low,
  medium,
  high,
  critical;

  Color get color {
    switch (this) {
      case DangerZoneRiskLevel.low:
        return const Color(0xFFFFF59D);
      case DangerZoneRiskLevel.medium:
        return const Color(0xFFFFD700);
      case DangerZoneRiskLevel.high:
        return const Color(0xFFFF6B00);
      case DangerZoneRiskLevel.critical:
        return const Color(0xFFFF0000);
    }
  }

  String get displayName {
    switch (this) {
      case DangerZoneRiskLevel.low:
        return 'Low Risk';
      case DangerZoneRiskLevel.medium:
        return 'Medium Risk';
      case DangerZoneRiskLevel.high:
        return 'High Risk';
      case DangerZoneRiskLevel.critical:
        return 'Critical Risk';
    }
  }

  bool get shouldNotify {
    return this == DangerZoneRiskLevel.high ||
        this == DangerZoneRiskLevel.critical;
  }
}

class DangerZoneEntity {
  final String id;
  final double latitude;
  final double longitude;
  final String gridCellId;
  final int incidentCount;
  final double riskScore;
  final DangerZoneRiskLevel riskLevel;
  final DateTime calculatedAt;

  DangerZoneEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.gridCellId,
    required this.incidentCount,
    required this.riskScore,
    required this.riskLevel,
    required this.calculatedAt,
  });

  double distanceFrom(double lat, double lon) {
    const radius = 6371000.0;
    final dLat = _toRadians(lat - latitude);
    final dLon = _toRadians(lon - longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(lat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return radius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;

  bool isWithinRadius(double lat, double lon, double radiusMeters) {
    return distanceFrom(lat, lon) <= radiusMeters;
  }
}
