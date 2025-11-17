import 'package:rpa/data/models/enums/risk_type.dart';
import 'package:rpa/data/models/websocket/alert_model.dart';
import 'package:rpa/data/models/websocket/report_model.dart';

// ============================================================================
// MOCK DATA - FOR TESTING PURPOSES ONLY
// ============================================================================
// This file contains mock alerts and reports for testing the map markers UI
// TODO: Replace with real WebSocket data from backend
// Based on test locations from the WebSocket documentation
// See: https://github.com/risk-place-angola/backend-risk-place/blob/develop/docs/MOBILE_WEBSOCKET_INTEGRATION.md#test-users
// ============================================================================

class MockMapData {
  // MOCK used for testing - Temporary alerts data for UI development
  /// Mock alerts for testing map markers and alert visualization
  static List<AlertModel> getMockAlerts() {
    return [
      // Violence alert - Morro Bento area
      AlertModel(
        alertId: '550e8400-e29b-41d4-a716-446655440000',
        message: 'Tiroteio reportado na área do Morro Bento',
        latitude: -8.842560,
        longitude: 13.300120,
        radius: 5000,
        riskType: RiskType.violence,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),

      // Fire alert - near Talatona
      AlertModel(
        alertId: '550e8400-e29b-41d4-a716-446655440001',
        message: 'Incêndio em edifício comercial na Talatona',
        latitude: -8.903290,
        longitude: 13.312540,
        radius: 3000,
        riskType: RiskType.fire,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),

      // Traffic alert - main road
      AlertModel(
        alertId: '550e8400-e29b-41d4-a716-446655440002',
        message: 'Acidente grave na Estrada de Catete, trânsito lento',
        latitude: -8.839987,
        longitude: 13.289437,
        radius: 2000,
        riskType: RiskType.traffic,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),

      // Flood alert - large area
      AlertModel(
        alertId: '550e8400-e29b-41d4-a716-446655440003',
        message: 'Inundação na área do Kilamba após chuvas fortes',
        latitude: -8.915120,
        longitude: 13.242380,
        radius: 10000,
        riskType: RiskType.flood,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  // MOCK used for testing - Temporary reports data for UI development
  /// Mock reports for testing map markers and report visualization
  static List<ReportModel> getMockReports() {
    return [
      // Infrastructure report - verified
      ReportModel(
        reportId: '7d3a4b10-f29c-41d4-a716-446655440001',
        message: 'Buraco grande na estrada principal do Gamek',
        latitude: -8.828765,
        longitude: 13.247865,
        riskType: RiskType.infrastructure,
        status: ReportStatus.verified,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),

      // Traffic report - pending
      ReportModel(
        reportId: '7d3a4b10-f29c-41d4-a716-446655440002',
        message: 'Semáforo quebrado no cruzamento da Mutamba',
        latitude: -8.810245,
        longitude: 13.236548,
        riskType: RiskType.infrastructure,
        status: ReportStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),

      // Violence report - verified
      ReportModel(
        reportId: '7d3a4b10-f29c-41d4-a716-446655440003',
        message: 'Assalto reportado próximo ao mercado',
        latitude: -8.855120,
        longitude: 13.275380,
        riskType: RiskType.violence,
        status: ReportStatus.verified,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),

      // Infrastructure report - resolved
      ReportModel(
        reportId: '7d3a4b10-f29c-41d4-a716-446655440004',
        message: 'Poste de luz caído na Rua Principal',
        latitude: -8.868900,
        longitude: 13.298600,
        riskType: RiskType.infrastructure,
        status: ReportStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // Fire report - pending
      ReportModel(
        reportId: '7d3a4b10-f29c-41d4-a716-446655440005',
        message: 'Fumaça intensa vindo de terreno baldio',
        latitude: -8.892345,
        longitude: 13.305678,
        riskType: RiskType.fire,
        status: ReportStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),

      // Flood report - verified
      ReportModel(
        reportId: '7d3a4b10-f29c-41d4-a716-446655440006',
        message: 'Rua alagada, impossível passar',
        latitude: -8.925678,
        longitude: 13.258900,
        riskType: RiskType.flood,
        status: ReportStatus.verified,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),

      // Traffic report - pending
      ReportModel(
        reportId: '7d3a4b10-f29c-41d4-a716-446655440007',
        message: 'Veículo quebrado bloqueando faixa',
        latitude: -8.845120,
        longitude: 13.285400,
        riskType: RiskType.traffic,
        status: ReportStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ];
  }

  // MOCK used for testing - Helper method to load all mock data
  /// Load all mock data into a provider (TEMPORARY - will be replaced by WebSocket)
  static void loadMockData(
    void Function(AlertModel) addAlert,
    void Function(ReportModel) addReport,
  ) {
    for (final alert in getMockAlerts()) {
      addAlert(alert);
    }
    for (final report in getMockReports()) {
      addReport(report);
    }
  }
}
