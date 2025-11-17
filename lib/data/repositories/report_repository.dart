import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rpa/constants.dart';
import 'package:rpa/data/dtos/create_report_request_dto.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/data/repositories/i_report_repository.dart';

/// Implementação do repositório de Reports
class ReportRepository implements IReportRepository {
  final String baseUrl = BASE_URL;
  final String? _authToken;

  ReportRepository({required String? authToken}) : _authToken = authToken;

  @override
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
  }) async {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Authentication token required');
    }

    final requestBody = {
      'risk_type_id': riskTypeId,
      'risk_topic_id': riskTopicId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'municipality': municipality,
      'neighborhood': neighborhood,
      'address': address,
      'image_url': imageUrl,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final data = jsonData['data'] as Map<String, dynamic>;
        return ReportResponseDTO.fromJson(data);
      } else {
        throw Exception(
          'Failed to create report: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }

  @override
  Future<ListNearbyReportsResponseDTO> fetchNearbyReports({
    required double latitude,
    required double longitude,
    double radius = 5000,
    List<String> statuses = const ['verified', 'pending'],
    int limit = 50,
    int offset = 0,
  }) async {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Authentication token required');
    }

    // Construir query parameters
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radius.toString(),
      'status': statuses.join(','),
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final uri = Uri.parse('$baseUrl/reports/nearby')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ListNearbyReportsResponseDTO.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch nearby reports: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching nearby reports: $e');
    }
  }

  @override
  Future<void> verifyReport(String reportId) async {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Authentication token required');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports/$reportId/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to verify report: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error verifying report: $e');
    }
  }

  @override
  Future<void> resolveReport(String reportId) async {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Authentication token required');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports/$reportId/resolve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to resolve report: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error resolving report: $e');
    }
  }
}
