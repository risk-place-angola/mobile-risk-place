import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/route.service.dart';
import 'package:rpa/data/services/i_route_service.dart';
import 'package:rpa/data/dtos/heatmap_request_dto.dart';
import 'package:rpa/data/dtos/heatmap_response_dto.dart';

final getIncidentsHeatmapUseCaseProvider = Provider<GetIncidentsHeatmapUseCase>(
  (ref) {
    final routeService = ref.read(routeServiceProvider);
    return GetIncidentsHeatmapUseCase(routeService: routeService);
  },
);

class GetIncidentsHeatmapUseCase {
  final IRouteService _routeService;

  GetIncidentsHeatmapUseCase({required IRouteService routeService})
      : _routeService = routeService;

  Future<HeatmapResponseDTO> execute({
    required double northEastLat,
    required double northEastLon,
    required double southWestLat,
    required double southWestLon,
    String? startDate,
    String? endDate,
    String? riskTypeId,
  }) async {
    final request = HeatmapRequestDTO(
      northEastLat: northEastLat,
      northEastLon: northEastLon,
      southWestLat: southWestLat,
      southWestLon: southWestLon,
      startDate: startDate,
      endDate: endDate,
      riskTypeId: riskTypeId,
    );

    return await _routeService.getIncidentsHeatmap(request: request);
  }
}
