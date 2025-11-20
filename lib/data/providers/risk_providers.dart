import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/data/dtos/risk_type_dto.dart';
import 'package:rpa/data/dtos/risk_topic_dto.dart';
import 'package:rpa/data/services/risk.service.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// Provider para o RiskService
final riskServiceProvider = Provider<RiskService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return RiskService(httpClient);
});

// ============================================================================
// RISK TYPES - CACHE GLOBAL
// ============================================================================

/// Provider para todos os risk types (cache global)
/// Este provider mantém todos os tipos em memória e não expira automaticamente
final allRiskTypesProvider = FutureProvider<List<RiskTypeDTO>>((ref) async {
  final service = ref.watch(riskServiceProvider);
  return service.listRiskTypes();
});

/// Provider para um risk type específico por ID (com cache)
/// Usa .family para criar um provider por ID
/// Usa .autoDispose para liberar memória quando não está mais em uso
final riskTypeProvider =
    FutureProvider.family<RiskTypeDTO, String>((ref, id) async {
  final service = ref.watch(riskServiceProvider);

  // Tenta primeiro buscar dos tipos já carregados (cache global)
  final allTypesAsync = ref.watch(allRiskTypesProvider);

  return allTypesAsync.when(
    data: (allTypes) {
      // Se já temos todos os tipos carregados, busca localmente
      final cached = allTypes.where((type) => type.id == id).firstOrNull;
      if (cached != null) {
        return Future.value(cached);
      }
      // Se não encontrou, busca da API
      return service.getRiskType(id);
    },
    loading: () {
      // Se ainda está carregando a lista completa, busca diretamente
      return service.getRiskType(id);
    },
    error: (_, __) {
      // Se houve erro ao carregar a lista, busca diretamente
      return service.getRiskType(id);
    },
  );
});

// ============================================================================
// RISK TOPICS - CACHE POR TIPO
// ============================================================================

/// Provider para risk topics de um risk type específico (com cache por tipo)
/// Se riskTypeId for null, retorna todos os topics
final riskTopicsProvider =
    FutureProvider.family<List<RiskTopicDTO>, String?>((ref, riskTypeId) async {
  final service = ref.watch(riskServiceProvider);
  return service.listRiskTopics(riskTypeId: riskTypeId);
});

/// Provider para um risk topic específico por ID (com cache)
final riskTopicProvider =
    FutureProvider.family<RiskTopicDTO, String>((ref, id) async {
  final service = ref.watch(riskServiceProvider);

  // Tenta primeiro buscar dos topics já carregados (cache)
  // Verifica se existe algum cache de topics carregados
  final allTopicsAsync = ref.watch(riskTopicsProvider(null));

  return allTopicsAsync.when(
    data: (allTopics) {
      // Se já temos topics carregados, busca localmente
      final cached = allTopics.where((topic) => topic.id == id).firstOrNull;
      if (cached != null) {
        return Future.value(cached);
      }
      // Se não encontrou, busca da API
      return service.getRiskTopic(id);
    },
    loading: () {
      // Se ainda está carregando, busca diretamente
      return service.getRiskTopic(id);
    },
    error: (_, __) {
      // Se houve erro, busca diretamente
      return service.getRiskTopic(id);
    },
  );
});

// ============================================================================
// HELPER PROVIDERS
// ============================================================================

/// Provider auxiliar para obter o nome de um risk type por ID
/// Retorna o nome ou "Unknown" se não encontrado
final riskTypeNameProvider = Provider.family<String, String>((ref, id) {
  final riskTypeAsync = ref.watch(riskTypeProvider(id));

  return riskTypeAsync.when(
    data: (riskType) => riskType.name,
    loading: () => 'Loading...',
    error: (_, __) => 'Unknown',
  );
});

/// Provider auxiliar para obter o nome de um risk topic por ID
/// Retorna o nome ou "Unknown" se não encontrado
final riskTopicNameProvider = Provider.family<String, String>((ref, id) {
  final riskTopicAsync = ref.watch(riskTopicProvider(id));

  return riskTopicAsync.when(
    data: (riskTopic) => riskTopic.name,
    loading: () => 'Loading...',
    error: (_, __) => 'Unknown',
  );
});
