import 'dart:developer';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/managers/settings_manager.dart';

final dangerZonesCalculatorProvider = Provider<DangerZonesCalculator>((ref) {
  final settingsManager = ref.watch(settingsManagerProvider);
  return DangerZonesCalculator(settingsManager);
});

class DangerZone {
  final double latitude;
  final double longitude;
  final int incidentCount;
  final double radius;
  final DateTime lastIncident;
  final Map<String, int> severityBreakdown;

  DangerZone({
    required this.latitude,
    required this.longitude,
    required this.incidentCount,
    required this.radius,
    required this.lastIncident,
    required this.severityBreakdown,
  });

  double get dangerScore {
    final critical = severityBreakdown['critical'] ?? 0;
    final high = severityBreakdown['high'] ?? 0;
    final medium = severityBreakdown['medium'] ?? 0;
    final low = severityBreakdown['low'] ?? 0;

    return (critical * 10 + high * 5 + medium * 2 + low * 1).toDouble();
  }
}

class IncidentRecord {
  final double latitude;
  final double longitude;
  final String severity;
  final DateTime timestamp;

  IncidentRecord({
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.timestamp,
  });
}

class DangerZonesCalculator {
  final SettingsManager _settingsManager;
  final Queue<IncidentRecord> _incidents = Queue();
  final Map<String, DangerZone> _zones = {};
  static const int _maxIncidentHistory = 5000;
  static const double _clusterRadius = 500.0;
  static const int _minIncidentsForZone = 5;
  static const Duration _historyWindow = Duration(days: 30);

  DangerZonesCalculator(this._settingsManager);

  void addIncident(
    double latitude,
    double longitude,
    String severity,
  ) {
    if (!_settingsManager.isDangerZonesEnabled) {
      return;
    }

    final incident = IncidentRecord(
      latitude: latitude,
      longitude: longitude,
      severity: severity,
      timestamp: DateTime.now(),
    );

    _incidents.addLast(incident);

    if (_incidents.length > _maxIncidentHistory) {
      _incidents.removeFirst();
    }

    _cleanOldIncidents();
    _recalculateZones();
  }

  void _cleanOldIncidents() {
    final cutoff = DateTime.now().subtract(_historyWindow);
    while (
        _incidents.isNotEmpty && _incidents.first.timestamp.isBefore(cutoff)) {
      _incidents.removeFirst();
    }
  }

  void _recalculateZones() {
    if (_incidents.length < _minIncidentsForZone) {
      return;
    }

    _zones.clear();
    final grid = <String, List<IncidentRecord>>{};

    for (var incident in _incidents) {
      final gridKey = _getGridKey(incident.latitude, incident.longitude);
      grid.putIfAbsent(gridKey, () => []).add(incident);
    }

    for (var entry in grid.entries) {
      final incidents = entry.value;
      if (incidents.length < _minIncidentsForZone) {
        continue;
      }

      final centerLat = _calculateCentroidLat(incidents);
      final centerLon = _calculateCentroidLon(incidents);
      final severityBreakdown = <String, int>{};

      for (var incident in incidents) {
        severityBreakdown[incident.severity] =
            (severityBreakdown[incident.severity] ?? 0) + 1;
      }

      final zone = DangerZone(
        latitude: centerLat,
        longitude: centerLon,
        incidentCount: incidents.length,
        radius: _clusterRadius,
        lastIncident: incidents
            .map((i) => i.timestamp)
            .reduce((a, b) => a.isAfter(b) ? a : b),
        severityBreakdown: severityBreakdown,
      );

      _zones[entry.key] = zone;
    }

    if (_zones.isNotEmpty) {
      log('Danger zones calculated: ${_zones.length} zones',
          name: 'DangerZonesCalculator');
    }
  }

  String _getGridKey(double lat, double lon) {
    final latGrid = (lat * 1000).round();
    final lonGrid = (lon * 1000).round();
    return '$latGrid:$lonGrid';
  }

  double _calculateCentroidLat(List<IncidentRecord> incidents) {
    if (incidents.isEmpty) return 0.0;
    return incidents.map((i) => i.latitude).reduce((a, b) => a + b) /
        incidents.length;
  }

  double _calculateCentroidLon(List<IncidentRecord> incidents) {
    if (incidents.isEmpty) return 0.0;
    return incidents.map((i) => i.longitude).reduce((a, b) => a + b) /
        incidents.length;
  }

  DangerZone? findNearestDangerZone(double latitude, double longitude) {
    if (!_settingsManager.isDangerZonesEnabled || _zones.isEmpty) {
      return null;
    }

    DangerZone? nearest;
    double minDistance = double.infinity;

    for (var zone in _zones.values) {
      final distance = _settingsManager.calculateDistance(
        latitude,
        longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance < zone.radius && distance < minDistance) {
        minDistance = distance;
        nearest = zone;
      }
    }

    return nearest;
  }

  List<DangerZone> findDangerZonesInRadius(
    double latitude,
    double longitude,
    double radiusMeters,
  ) {
    if (!_settingsManager.isDangerZonesEnabled) {
      return [];
    }

    final zones = <DangerZone>[];

    for (var zone in _zones.values) {
      final distance = _settingsManager.calculateDistance(
        latitude,
        longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance <= radiusMeters) {
        zones.add(zone);
      }
    }

    zones.sort((a, b) => b.dangerScore.compareTo(a.dangerScore));
    return zones;
  }

  List<DangerZone> getTopDangerZones(int limit) {
    final zones = _zones.values.toList();
    zones.sort((a, b) => b.dangerScore.compareTo(a.dangerScore));
    return zones.take(limit).toList();
  }

  void clear() {
    _incidents.clear();
    _zones.clear();
    log('Danger zones cleared', name: 'DangerZonesCalculator');
  }

  int get zoneCount => _zones.length;
  int get incidentCount => _incidents.length;
  bool get isEnabled => _settingsManager.isDangerZonesEnabled;
}
