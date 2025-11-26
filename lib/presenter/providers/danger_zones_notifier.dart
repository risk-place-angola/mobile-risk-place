import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/danger_zone.dart';
import 'package:rpa/domain/usecases/get_danger_zones_usecase.dart';

final dangerZonesNotifierProvider =
    NotifierProvider<DangerZonesNotifier, DangerZonesState>(
  DangerZonesNotifier.new,
);

class DangerZonesState {
  final List<DangerZoneEntity> zones;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  DangerZonesState({
    this.zones = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  DangerZonesState copyWith({
    List<DangerZoneEntity>? zones,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return DangerZonesState(
      zones: zones ?? this.zones,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  int get highRiskCount =>
      zones.where((z) => z.riskLevel == DangerZoneRiskLevel.high).length;

  int get criticalRiskCount =>
      zones.where((z) => z.riskLevel == DangerZoneRiskLevel.critical).length;

  bool get hasHighRiskZones => highRiskCount > 0 || criticalRiskCount > 0;
}

class DangerZonesNotifier extends Notifier<DangerZonesState> {
  @override
  DangerZonesState build() {
    return DangerZonesState();
  }

  Future<void> loadDangerZones({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) {
      log('[DangerZonesNotifier] Already loading, skipping');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getDangerZonesUseCaseProvider);
      final params = GetDangerZonesParams(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        forceRefresh: forceRefresh,
      );

      final result = await useCase.execute(params);

      if (result is GetDangerZonesSuccess) {
        state = state.copyWith(
          zones: result.zones,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else if (result is GetDangerZonesFailure) {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      log('[DangerZonesNotifier] Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  DangerZoneEntity? findNearestDangerZone(
    double latitude,
    double longitude,
  ) {
    if (state.zones.isEmpty) return null;

    DangerZoneEntity? nearest;
    double minDistance = double.infinity;

    for (final zone in state.zones) {
      final distance = zone.distanceFrom(latitude, longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = zone;
      }
    }

    return nearest;
  }

  List<DangerZoneEntity> getZonesInRadius(
    double latitude,
    double longitude,
    double radiusMeters,
  ) {
    return state.zones
        .where((zone) => zone.isWithinRadius(latitude, longitude, radiusMeters))
        .toList();
  }
}
