import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/data/models/enums/risk_type.dart';
import 'package:rpa/data/models/websocket/alert_model.dart';
import 'package:rpa/data/models/websocket/report_model.dart';
import 'package:rpa/presenter/pages/map/widgets/map_markers.dart';

/// State class to manage alerts and reports on the map
class MapMarkersState {
  final List<AlertModel> alerts;
  final List<ReportModel> reports;

  const MapMarkersState({
    this.alerts = const [],
    this.reports = const [],
  });

  MapMarkersState copyWith({
    List<AlertModel>? alerts,
    List<ReportModel>? reports,
  }) {
    return MapMarkersState(
      alerts: alerts ?? this.alerts,
      reports: reports ?? this.reports,
    );
  }
}

/// Notifier to manage map markers (alerts and reports)
class MapMarkersNotifier extends Notifier<MapMarkersState> {
  @override
  MapMarkersState build() => const MapMarkersState();

  /// Add a new alert from WebSocket
  void addAlert(AlertModel alert) {
    // Check if alert already exists
    final exists = state.alerts.any((a) => a.alertId == alert.alertId);
    if (!exists) {
      state = state.copyWith(
        alerts: [...state.alerts, alert],
      );
    }
  }

  /// Add a new report from WebSocket
  void addReport(ReportModel report) {
    // Check if report already exists
    final exists = state.reports.any((r) => r.reportId == report.reportId);
    if (!exists) {
      state = state.copyWith(
        reports: [...state.reports, report],
      );
    }
  }

  /// Update a report status (verified or resolved)
  void updateReportStatus(String reportId, ReportStatus status) {
    final updatedReports = state.reports.map((report) {
      if (report.reportId == reportId) {
        return report.copyWith(status: status);
      }
      return report;
    }).toList();

    state = state.copyWith(reports: updatedReports);
  }

  /// Remove an alert by ID
  void removeAlert(String alertId) {
    state = state.copyWith(
      alerts: state.alerts.where((a) => a.alertId != alertId).toList(),
    );
  }

  /// Remove a report by ID
  void removeReport(String reportId) {
    state = state.copyWith(
      reports: state.reports.where((r) => r.reportId != reportId).toList(),
    );
  }

  /// Clear all alerts
  void clearAlerts() {
    state = state.copyWith(alerts: []);
  }

  /// Clear all reports
  void clearReports() {
    state = state.copyWith(reports: []);
  }

  /// Clear everything
  void clearAll() {
    state = const MapMarkersState();
  }

  /// Get all markers (alerts + reports) for the map with click handlers
  List<Marker> getAllMarkersWithContext(void Function(dynamic) onTap) {
    final List<Marker> markers = [];

    // Add alert markers
    for (final alert in state.alerts) {
      markers.add(
        Marker(
          width: 60,
          height: 60,
          point: LatLng(alert.latitude, alert.longitude),
          child: GestureDetector(
            onTap: () => onTap(alert),
            child: AlertMarkerWidget(
              riskType: alert.riskType ?? 
                  _inferRiskTypeFromMessage(alert.message),
            ),
          ),
        ),
      );
    }

    // Add report markers
    for (final report in state.reports) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(report.latitude, report.longitude),
          child: GestureDetector(
            onTap: () => onTap(report),
            child: ReportMarkerWidget(
              riskType: report.riskType ??
                  _inferRiskTypeFromMessage(report.message),
              topicName: report.riskTopicName,
              topicIconUrl: report.riskTopicIconUrl,
              isVerified: report.status == ReportStatus.verified,
              isResolved: report.status == ReportStatus.resolved,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// Get all alert radius circles
  List<CircleMarker> getAlertRadiusCircles() {
    return state.alerts.map((alert) {
      return CircleMarker(
        point: LatLng(alert.latitude, alert.longitude),
        radius: alert.radius,
        useRadiusInMeter: true,
        color: AlertRadiusHelper.getRadiusColor(
          alert.riskType ?? _inferRiskTypeFromMessage(alert.message),
          opacity: 0.15,
        ),
        borderColor: AlertRadiusHelper.getRadiusColor(
          alert.riskType ?? _inferRiskTypeFromMessage(alert.message),
          opacity: 0.3,
        ),
        borderStrokeWidth: 2,
      );
    }).toList();
  }

  /// Load mock data for testing
  void loadMockData(List<AlertModel> mockAlerts, List<ReportModel> mockReports) {
    state = MapMarkersState(
      alerts: mockAlerts,
      reports: mockReports,
    );
  }
}

/// Provider for map markers notifier
final mapMarkersProvider =
    NotifierProvider<MapMarkersNotifier, MapMarkersState>(
  MapMarkersNotifier.new,
);

/// Provider for getting alert radius circles
final alertRadiusCirclesProvider = Provider<List<CircleMarker>>((ref) {
  final notifier = ref.watch(mapMarkersProvider.notifier);
  ref.watch(mapMarkersProvider); // Watch state changes
  return notifier.getAlertRadiusCircles();
});

/// Helper to infer risk type from message
RiskType _inferRiskTypeFromMessage(String message) {
  final lowerMessage = message.toLowerCase();

  if (lowerMessage.contains('tiroteio') ||
      lowerMessage.contains('assalto') ||
      lowerMessage.contains('violência') ||
      lowerMessage.contains('violencia')) {
    return RiskType.violence;
  } else if (lowerMessage.contains('fogo') ||
      lowerMessage.contains('incêndio') ||
      lowerMessage.contains('incendio')) {
    return RiskType.fire;
  } else if (lowerMessage.contains('acidente') ||
      lowerMessage.contains('trânsito') ||
      lowerMessage.contains('transito') ||
      lowerMessage.contains('estrada')) {
    return RiskType.traffic;
  } else if (lowerMessage.contains('buraco') ||
      lowerMessage.contains('infraestrutura') ||
      lowerMessage.contains('luz')) {
    return RiskType.infrastructure;
  } else if (lowerMessage.contains('inundação') ||
      lowerMessage.contains('inundacao') ||
      lowerMessage.contains('chuva') ||
      lowerMessage.contains('água') ||
      lowerMessage.contains('agua')) {
    return RiskType.naturalDisaster;
  }

  return RiskType.infrastructure;
}
