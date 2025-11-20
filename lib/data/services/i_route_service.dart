import 'package:rpa/data/dtos/calculate_safe_route_request_dto.dart';
import 'package:rpa/data/dtos/safe_route_response_dto.dart';
import 'package:rpa/data/dtos/heatmap_request_dto.dart';
import 'package:rpa/data/dtos/heatmap_response_dto.dart';

abstract class IRouteService {
  Future<SafeRouteResponseDTO> calculateSafeRoute({
    required CalculateSafeRouteRequestDTO request,
  });

  Future<HeatmapResponseDTO> getIncidentsHeatmap({
    required HeatmapRequestDTO request,
  });
}
