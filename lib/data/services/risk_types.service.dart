import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/risk_type_response_dto.dart';
import 'package:rpa/data/dtos/risk_topic_response_dto.dart';

final riskTypesServiceProvider = Provider<RiskTypesService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return RiskTypesService(httpClient: httpClient);
});

/// Service to manage Risk Types and Topics
class RiskTypesService {
  final IHttpClient _httpClient;

  RiskTypesService({required IHttpClient httpClient}) : _httpClient = httpClient;

  /// Fetch all risk types
  Future<List<RiskTypeResponseDTO>> getRiskTypes() async {
    try {
      log('Fetching risk types...', name: 'RiskTypesService');
      
      final response = await _httpClient.get('/risks/types');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List;
        final riskTypes = data.map((json) => RiskTypeResponseDTO.fromJson(json)).toList();
        
        log('Successfully fetched ${riskTypes.length} risk types', name: 'RiskTypesService');
        return riskTypes;
      } else {
        throw ServerException(
          message: 'Falha ao buscar tipos de risco',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error fetching risk types: $e', name: 'RiskTypesService');
      throw ServerException(message: 'Erro inesperado ao buscar tipos de risco');
    }
  }

  /// Fetch all risk topics (optionally filtered by risk type)
  Future<List<RiskTopicResponseDTO>> getRiskTopics({String? riskTypeId}) async {
    try {
      log('Fetching risk topics${riskTypeId != null ? ' for type $riskTypeId' : ''}...', 
          name: 'RiskTypesService');
      
      final queryParams = riskTypeId != null ? {'risk_type_id': riskTypeId} : null;
      final response = await _httpClient.get('/risks/topics', queryParameters: queryParams);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List;
        final riskTopics = data.map((json) => RiskTopicResponseDTO.fromJson(json)).toList();
        
        log('Successfully fetched ${riskTopics.length} risk topics', name: 'RiskTypesService');
        return riskTopics;
      } else {
        throw ServerException(
          message: 'Falha ao buscar tópicos de risco',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error fetching risk topics: $e', name: 'RiskTypesService');
      throw ServerException(message: 'Erro inesperado ao buscar tópicos de risco');
    }
  }
}
