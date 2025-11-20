import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rpa/constants.dart';
import 'package:rpa/data/dtos/risk_type_response_dto.dart';
import 'package:rpa/data/dtos/risk_topic_response_dto.dart';
import 'package:rpa/data/repositories/i_risk_types_repository.dart';

/// Implementação do repositório de Risk Types
class RiskTypesRepository implements IRiskTypesRepository {
  final String baseUrl = BASE_URL;
  final String? _authToken;

  // Cache interno
  final Map<String, String> _typeNameToId = {};
  final Map<String, String> _topicNameToId = {};
  bool _initialized = false;

  RiskTypesRepository({required String? authToken}) : _authToken = authToken;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Buscar types e topics em paralelo
      final results = await Future.wait([
        fetchRiskTypes(),
        fetchRiskTopics(),
      ]);

      final typesResponse = results[0] as ListRiskTypesResponseDTO;
      final topicsResponse = results[1] as ListRiskTopicsResponseDTO;

      // Popular cache de types
      _typeNameToId.clear();
      for (final type in typesResponse.data) {
        _typeNameToId[type.name] = type.id;
      }

      // Popular cache de topics
      _topicNameToId.clear();
      for (final topic in topicsResponse.data) {
        _topicNameToId[topic.name] = topic.id;
      }

      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize RiskTypesRepository: $e');
    }
  }

  @override
  Future<ListRiskTypesResponseDTO> fetchRiskTypes() async {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Authentication token required');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/risks/types'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ListRiskTypesResponseDTO.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch risk types: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching risk types: $e');
    }
  }

  @override
  Future<ListRiskTopicsResponseDTO> fetchRiskTopics() async {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Authentication token required');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/risks/topics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ListRiskTopicsResponseDTO.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch risk topics: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching risk topics: $e');
    }
  }

  @override
  String? getRiskTypeId(String name) {
    if (!_initialized) {
      throw Exception(
          'RiskTypesRepository not initialized. Call initialize() first.');
    }
    return _typeNameToId[name];
  }

  @override
  String? getRiskTopicId(String name) {
    if (!_initialized) {
      throw Exception(
          'RiskTypesRepository not initialized. Call initialize() first.');
    }
    return _topicNameToId[name];
  }
}
