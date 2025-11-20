import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/route.service.dart';
import 'package:rpa/data/services/i_route_service.dart';
import 'package:rpa/data/dtos/calculate_safe_route_request_dto.dart';
import 'package:rpa/data/dtos/safe_route_response_dto.dart';

final calculateSafeRouteUseCaseProvider = Provider<CalculateSafeRouteUseCase>(
  (ref) {
    final routeService = ref.read(routeServiceProvider);
    return CalculateSafeRouteUseCase(routeService: routeService);
  },
);

class CalculateSafeRouteUseCase {
  final IRouteService _routeService;

  CalculateSafeRouteUseCase({required IRouteService routeService})
      : _routeService = routeService;

  Future<SafeRouteResponseDTO> execute({
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
    int maxRoutes = 1,
  }) async {
    final request = CalculateSafeRouteRequestDTO(
      originLat: originLat,
      originLon: originLon,
      destinationLat: destinationLat,
      destinationLon: destinationLon,
      maxRoutes: maxRoutes,
    );

    return await _routeService.calculateSafeRoute(request: request);
  }
}
