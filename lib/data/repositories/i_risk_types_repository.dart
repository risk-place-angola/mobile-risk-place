import 'package:rpa/data/dtos/risk_type_response_dto.dart';
import 'package:rpa/data/dtos/risk_topic_response_dto.dart';

/// Interface para operações com Risk Types e Topics
abstract class IRiskTypesRepository {
  /// Buscar todos os tipos de risco do backend
  Future<ListRiskTypesResponseDTO> fetchRiskTypes();

  /// Buscar todos os tópicos de risco do backend
  Future<ListRiskTopicsResponseDTO> fetchRiskTopics();

  /// Obter ID do tipo de risco pelo nome
  String? getRiskTypeId(String name);

  /// Obter ID do tópico de risco pelo nome
  String? getRiskTopicId(String name);

  /// Verificar se o repositório foi inicializado
  bool get isInitialized;

  /// Inicializar cache de types e topics
  Future<void> initialize();
}
