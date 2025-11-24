import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/create_report_request_dto.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/data/dtos/list_reports_response_dto.dart';
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

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }
      log('Report created successfully: ${response.data['id']}',
          name: 'ReportService');
      return ReportResponseDTO.fromJson(response.data);
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
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }
      
      final List<dynamic> dataList =
          response.data is List ? response.data : response.data['data'] ?? [];

      final reports =
          dataList.map((json) => NearbyReportDTO.fromJson(json)).toList();

      log('Successfully fetched ${reports.length} nearby reports',
          name: 'ReportService');
      return reports;
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error fetching nearby reports: $e',
          name: 'ReportService');
      throw ServerException(message: 'Erro inesperado ao buscar relatórios');
    }
  }

  /// List all reports with pagination - GET /reports
  ///
  /// This is the proper endpoint for listing ALL reports in the system.
  /// Use this for admin screens, dashboards, and global report listings.
  Future<ListReportsResponseDTO> listAllReports({
    int page = 1,
    int limit = 20,
    String? status,
    String sort = 'created_at',
    String order = 'desc',
  }) async {
    try {
      log('Fetching all reports (page: $page, limit: $limit, status: $status)...',
          name: 'ReportService');

      final response = await _httpClient.get(
        '/reports',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
          'sort': sort,
          'order': order,
        },
      );

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }
      
      final result = ListReportsResponseDTO.fromJson(response.data);
      log('Successfully fetched ${result.data.length} reports (total: ${result.pagination.total})',
          name: 'ReportService');
      return result;
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error fetching all reports: $e', name: 'ReportService');
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

      await _httpClient.post(
        '/reports/$reportId/verify',
        data: {'moderator_id': moderatorId},
      );

      // If we get here, request was successful (200-299)
      log('Report verified successfully', name: 'ReportService');
      return true;
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

      await _httpClient.post(
        '/reports/$reportId/resolve',
        data: {'moderator_id': moderatorId},
      );

      // If we get here, request was successful (200-299)
      log('Report resolved successfully', name: 'ReportService');
      return true;
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

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }
      
      log('Report location updated successfully', name: 'ReportService');
      return UpdateReportLocationResponseDTO.fromJson(response.data);
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error updating report location: $e',
          name: 'ReportService');
      throw ServerException(
          message: 'Erro inesperado ao atualizar localização');
    }
  }
}
