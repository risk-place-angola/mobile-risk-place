import 'package:rpa/domain/entities/danger_zone.dart';

class DangerZoneRequestDto {
  final double latitude;
  final double longitude;
  final double radiusMeters;

  DangerZoneRequestDto({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
      };
}

class DangerZoneDto {
  final String id;
  final double latitude;
  final double longitude;
  final String gridCellId;
  final int incidentCount;
  final double riskScore;
  final String riskLevel;
  final DateTime calculatedAt;

  DangerZoneDto({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.gridCellId,
    required this.incidentCount,
    required this.riskScore,
    required this.riskLevel,
    required this.calculatedAt,
  });

  factory DangerZoneDto.fromJson(Map<String, dynamic> json) {
    return DangerZoneDto(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      gridCellId: json['grid_cell_id'] as String,
      incidentCount: json['incident_count'] as int,
      riskScore: (json['risk_score'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  DangerZoneEntity toEntity() {
    return DangerZoneEntity(
      id: id,
      latitude: latitude,
      longitude: longitude,
      gridCellId: gridCellId,
      incidentCount: incidentCount,
      riskScore: riskScore,
      riskLevel: _mapRiskLevel(riskLevel),
      calculatedAt: calculatedAt,
    );
  }

  DangerZoneRiskLevel _mapRiskLevel(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
        return DangerZoneRiskLevel.critical;
      case 'high':
        return DangerZoneRiskLevel.high;
      case 'medium':
        return DangerZoneRiskLevel.medium;
      case 'low':
        return DangerZoneRiskLevel.low;
      default:
        return DangerZoneRiskLevel.low;
    }
  }
}

class DangerZoneResponseDto {
  final List<DangerZoneDto> zones;
  final int totalCount;

  DangerZoneResponseDto({
    required this.zones,
    required this.totalCount,
  });

  factory DangerZoneResponseDto.fromJson(Map<String, dynamic> json) {
    return DangerZoneResponseDto(
      zones: (json['zones'] as List)
          .map((zone) => DangerZoneDto.fromJson(zone as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
    );
  }

  List<DangerZoneEntity> toEntities() {
    return zones.map((dto) => dto.toEntity()).toList();
  }
}
