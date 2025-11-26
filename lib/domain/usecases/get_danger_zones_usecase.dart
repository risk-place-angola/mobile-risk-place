import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/danger_zone.service.dart';
import 'package:rpa/domain/entities/danger_zone.dart';

final getDangerZonesUseCaseProvider = Provider<GetDangerZonesUseCase>((ref) {
  final service = ref.watch(dangerZoneServiceProvider);
  return GetDangerZonesUseCase(service: service);
});

class GetDangerZonesParams {
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool forceRefresh;

  GetDangerZonesParams({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 5000,
    this.forceRefresh = false,
  });

  String? validate() {
    if (latitude < -90 || latitude > 90) {
      return 'Latitude must be between -90 and 90';
    }
    if (longitude < -180 || longitude > 180) {
      return 'Longitude must be between -180 and 180';
    }
    if (radiusMeters < 100 || radiusMeters > 10000) {
      return 'Radius must be between 100 and 10000 meters';
    }
    return null;
  }
}

abstract class GetDangerZonesResult {}

class GetDangerZonesSuccess extends GetDangerZonesResult {
  final List<DangerZoneEntity> zones;
  final int highRiskCount;
  final int criticalRiskCount;

  GetDangerZonesSuccess({
    required this.zones,
    required this.highRiskCount,
    required this.criticalRiskCount,
  });
}

class GetDangerZonesFailure extends GetDangerZonesResult {
  final String error;

  GetDangerZonesFailure({required this.error});
}

class GetDangerZonesUseCase {
  final DangerZoneService _service;

  GetDangerZonesUseCase({required DangerZoneService service})
      : _service = service;

  Future<GetDangerZonesResult> execute(GetDangerZonesParams params) async {
    final validationError = params.validate();
    if (validationError != null) {
      log('[GetDangerZonesUseCase] Validation error: $validationError');
      return GetDangerZonesFailure(error: validationError);
    }

    try {
      log('[GetDangerZonesUseCase] Fetching danger zones');

      final zones = await _service.getNearbyDangerZones(
        latitude: params.latitude,
        longitude: params.longitude,
        radiusMeters: params.radiusMeters,
        forceRefresh: params.forceRefresh,
      );

      final highRiskCount =
          zones.where((z) => z.riskLevel == DangerZoneRiskLevel.high).length;
      final criticalRiskCount = zones
          .where((z) => z.riskLevel == DangerZoneRiskLevel.critical)
          .length;

      log('[GetDangerZonesUseCase] Success: ${zones.length} zones (${criticalRiskCount} critical, ${highRiskCount} high)');

      return GetDangerZonesSuccess(
        zones: zones,
        highRiskCount: highRiskCount,
        criticalRiskCount: criticalRiskCount,
      );
    } catch (e) {
      log('[GetDangerZonesUseCase] Error: $e');
      return GetDangerZonesFailure(error: e.toString());
    }
  }
}
