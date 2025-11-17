import 'package:rpa/data/dtos/create_report_request_dto.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';

/// Interface para operações com Reports
abstract class IReportRepository {
  /// Criar um novo report
  Future<ReportResponseDTO> createReport({
    required String riskTypeId,
    required String riskTopicId,
    required String description,
    required double latitude,
    required double longitude,
    String province = '',
    String municipality = '',
    String neighborhood = '',
    String address = '',
    String imageUrl = '',
  });

  /// Buscar reports próximos a uma localização
  Future<ListNearbyReportsResponseDTO> fetchNearbyReports({
    required double latitude,
    required double longitude,
    double radius = 5000,
    List<String> statuses = const ['verified', 'pending'],
    int limit = 50,
    int offset = 0,
  });

  /// Verificar um report (apenas autoridades)
  Future<void> verifyReport(String reportId);

  /// Resolver um report (marcar como resolvido)
  Future<void> resolveReport(String reportId);
}
