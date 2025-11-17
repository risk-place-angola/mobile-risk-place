import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/create_report_request_dto.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/data/dtos/update_report_location_dto.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return ReportService(httpClient: httpClient);
});

/// Service to create and manage reports
class ReportService {
  final IHttpClient _httpClient;

  ReportService({required IHttpClient httpClient}) : _httpClient = httpClient;

  /// Create a new report
  Future<ReportResponseDTO> createReport({
    required CreateReportRequestDTO reportData,
  }) async {
    try {
      log('Creating report...', name: 'ReportService');
      
      final response = await _httpClient.post(
        '/reports',
        data: reportData.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        log('Report created successfully: ${response.data['id']}', name: 'ReportService');
        return ReportResponseDTO.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Falha ao criar relatório',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error creating report: $e', name: 'ReportService');
      throw ServerException(message: 'Erro inesperado ao criar relatório');
    }
  }

  /// List nearby reports
  Future<List<NearbyReportDTO>> listNearbyReports({
    required double latitude,
    required double longitude,
    int radius = 500,
  }) async {
    try {
      log('Fetching nearby reports at ($latitude, $longitude) with radius $radius m...', 
          name: 'ReportService');
      
      final response = await _httpClient.get(
        '/reports/nearby',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'radius': radius,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final reports = dataList.map((json) => NearbyReportDTO.fromJson(json)).toList();
        
        log('Successfully fetched ${reports.length} nearby reports', name: 'ReportService');
        return reports;
      } else {
        throw ServerException(
          message: 'Falha ao buscar relatórios próximos',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error fetching nearby reports: $e', name: 'ReportService');
      throw ServerException(message: 'Erro inesperado ao buscar relatórios');
    }
  }

  /// Verify a report (moderator action)
  Future<bool> verifyReport({
    required String reportId,
    required String moderatorId,
  }) async {
    try {
      log('Verifying report: $reportId', name: 'ReportService');
      
      final response = await _httpClient.post(
        '/reports/$reportId/verify',
        data: {'moderator_id': moderatorId},
      );

      if (response.statusCode == 200) {
        log('Report verified successfully', name: 'ReportService');
        return true;
      } else {
        throw ServerException(
          message: 'Falha ao verificar relatório',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error verifying report: $e', name: 'ReportService');
      throw ServerException(message: 'Erro inesperado ao verificar relatório');
    }
  }

  /// Resolve a report (moderator action)
  Future<bool> resolveReport({
    required String reportId,
    required String moderatorId,
  }) async {
    try {
      log('Resolving report: $reportId', name: 'ReportService');
      
      final response = await _httpClient.post(
        '/reports/$reportId/resolve',
        data: {'moderator_id': moderatorId},
      );

      if (response.statusCode == 200) {
        log('Report resolved successfully', name: 'ReportService');
        return true;
      } else {
        throw ServerException(
          message: 'Falha ao resolver relatório',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error resolving report: $e', name: 'ReportService');
      throw ServerException(message: 'Erro inesperado ao resolver relatório');
    }
  }

  /// Update report location when user drags marker
  Future<UpdateReportLocationResponseDTO> updateReportLocation({
    required String reportId,
    required UpdateReportLocationRequestDTO locationData,
  }) async {
    try {
      log('Updating location for report: $reportId', name: 'ReportService');
      
      final response = await _httpClient.put(
        '/reports/$reportId/location',
        data: locationData.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        log('Report location updated successfully', name: 'ReportService');
        return UpdateReportLocationResponseDTO.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Falha ao atualizar localização do relatório',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error updating report location: $e', name: 'ReportService');
      throw ServerException(message: 'Erro inesperado ao atualizar localização');
    }
  }
}
