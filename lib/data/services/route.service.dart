import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/services/i_route_service.dart';
import 'package:rpa/data/dtos/calculate_safe_route_request_dto.dart';
import 'package:rpa/data/dtos/safe_route_response_dto.dart';
import 'package:rpa/data/dtos/heatmap_request_dto.dart';
import 'package:rpa/data/dtos/heatmap_response_dto.dart';

final routeServiceProvider = Provider<RouteService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return RouteService(httpClient: httpClient);
});

class RouteService implements IRouteService {
  final IHttpClient _httpClient;

  RouteService({required IHttpClient httpClient}) : _httpClient = httpClient;

  @override
  Future<SafeRouteResponseDTO> calculateSafeRoute({
    required CalculateSafeRouteRequestDTO request,
  }) async {
    try {
      log('Calculating safe route...', name: 'RouteService');

      final response = await _httpClient.post(
        '/routes/safe-route',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        log('Safe route calculated successfully', name: 'RouteService');
        return SafeRouteResponseDTO.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Falha ao calcular rota segura',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error calculating safe route: $e', name: 'RouteService');
      throw ServerException(message: 'Erro inesperado ao calcular rota segura');
    }
  }

  @override
  Future<HeatmapResponseDTO> getIncidentsHeatmap({
    required HeatmapRequestDTO request,
  }) async {
    try {
      log('Fetching incidents heatmap...', name: 'RouteService');

      final response = await _httpClient.post(
        '/routes/incidents-heatmap',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        log('Heatmap data fetched successfully', name: 'RouteService');
        return HeatmapResponseDTO.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Falha ao obter mapa de calor',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error fetching heatmap: $e', name: 'RouteService');
      throw ServerException(message: 'Erro inesperado ao obter mapa de calor');
    }
  }
}
