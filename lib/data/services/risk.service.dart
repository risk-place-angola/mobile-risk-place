import 'dart:developer' show log;

import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/data/dtos/risk_type_dto.dart';
import 'package:rpa/data/dtos/risk_topic_dto.dart';

/// Service para operações com Risk Types e Risk Topics
class RiskService {
  final IHttpClient _httpClient;

  RiskService(this._httpClient);

  // ============================================================================
  // RISK TYPES
  // ============================================================================

  /// Lista todos os risk types disponíveis
  Future<List<RiskTypeDTO>> listRiskTypes() async {
    try {
      log('Fetching all risk types', name: 'RiskService');

      final response = await _httpClient.get('/risks/types');
      
      final dto = ListRiskTypesResponseDTO.fromJson(response.data);
      
      log('Loaded ${dto.data.length} risk types', name: 'RiskService');
      
      return dto.data;
    } catch (e) {
      log('Error listing risk types: $e', name: 'RiskService');
      throw Exception('Failed to list risk types: $e');
    }
  }

  /// Busca um risk type específico por ID
  Future<RiskTypeDTO> getRiskType(String id) async {
    try {
      log('Fetching risk type: $id', name: 'RiskService');

      final response = await _httpClient.get('/risks/types/$id');
      
      final dto = RiskTypeDTO.fromJson(response.data);
      
      log('Loaded risk type: ${dto.name}', name: 'RiskService');
      
      return dto;
    } catch (e) {
      log('Error getting risk type $id: $e', name: 'RiskService');
      throw Exception('Failed to get risk type: $e');
    }
  }

  // ============================================================================
  // RISK TOPICS
  // ============================================================================

  /// Lista todos os risk topics (com filtro opcional por risk_type_id)
  Future<List<RiskTopicDTO>> listRiskTopics({String? riskTypeId}) async {
    try {
      log('Fetching risk topics${riskTypeId != null ? ' for type $riskTypeId' : ''}', 
          name: 'RiskService');

      final queryParams = <String, dynamic>{};
      if (riskTypeId != null) {
        queryParams['risk_type_id'] = riskTypeId;
      }

      final response = await _httpClient.get(
        '/risks/topics',
        queryParameters: queryParams,
      );
      
      final dto = ListRiskTopicsResponseDTO.fromJson(response.data);
      
      log('Loaded ${dto.data.length} risk topics', name: 'RiskService');
      
      return dto.data;
    } catch (e) {
      log('Error listing risk topics: $e', name: 'RiskService');
      throw Exception('Failed to list risk topics: $e');
    }
  }

  /// Busca um risk topic específico por ID
  Future<RiskTopicDTO> getRiskTopic(String id) async {
    try {
      log('Fetching risk topic: $id', name: 'RiskService');

      final response = await _httpClient.get('/risks/topics/$id');
      
      final dto = RiskTopicDTO.fromJson(response.data);
      
      log('Loaded risk topic: ${dto.name}', name: 'RiskService');
      
      return dto;
    } catch (e) {
      log('Error getting risk topic $id: $e', name: 'RiskService');
      throw Exception('Failed to get risk topic: $e');
    }
  }
}
