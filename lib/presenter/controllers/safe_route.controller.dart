import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/domain/usecases/calculate_safe_route_usecase.dart';
import 'package:rpa/domain/usecases/get_incidents_heatmap_usecase.dart';
import 'package:rpa/data/models/safe_route.dart';
import 'package:rpa/data/models/heatmap_point.dart';
import 'package:rpa/core/error/error_handler.dart';

enum RouteStatus { idle, loading, success, error }

final safeRouteControllerProvider =
    ChangeNotifierProvider<SafeRouteController>((ref) {
  final calculateRouteUseCase = ref.watch(calculateSafeRouteUseCaseProvider);
  final getHeatmapUseCase = ref.watch(getIncidentsHeatmapUseCaseProvider);
  return SafeRouteController(
    calculateRouteUseCase: calculateRouteUseCase,
    getHeatmapUseCase: getHeatmapUseCase,
  );
});

class SafeRouteController extends ChangeNotifier {
  final CalculateSafeRouteUseCase _calculateRouteUseCase;
  final GetIncidentsHeatmapUseCase _getHeatmapUseCase;

  RouteStatus _status = RouteStatus.idle;
  SafeRoute? _route;
  List<HeatmapPoint> _heatmapPoints = [];
  String? _errorMessage;
  LatLng? _selectedOrigin;
  LatLng? _selectedDestination;

  SafeRouteController({
    required CalculateSafeRouteUseCase calculateRouteUseCase,
    required GetIncidentsHeatmapUseCase getHeatmapUseCase,
  })  : _calculateRouteUseCase = calculateRouteUseCase,
        _getHeatmapUseCase = getHeatmapUseCase;

  RouteStatus get status => _status;
  SafeRoute? get route => _route;
  List<HeatmapPoint> get heatmapPoints => _heatmapPoints;
  String? get errorMessage => _errorMessage;
  LatLng? get selectedOrigin => _selectedOrigin;
  LatLng? get selectedDestination => _selectedDestination;

  void setOrigin(LatLng origin) {
    _selectedOrigin = origin;
    notifyListeners();
  }

  void setDestination(LatLng destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  Future<void> calculateSafeRoute({
    required LatLng origin,
    required LatLng destination,
    int maxRoutes = 1,
  }) async {
    try {
      _status = RouteStatus.loading;
      _selectedOrigin = origin;
      _selectedDestination = destination;
      _errorMessage = null;
      notifyListeners();

      final response = await _calculateRouteUseCase.execute(
        originLat: origin.latitude,
        originLon: origin.longitude,
        destinationLat: destination.latitude,
        destinationLon: destination.longitude,
        maxRoutes: maxRoutes,
      );

      _status = RouteStatus.success;
      _route = response.route;
      notifyListeners();
    } catch (e) {
      _status = RouteStatus.error;
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      notifyListeners();
    }
  }

  Future<void> loadHeatmap({
    required LatLng northEast,
    required LatLng southWest,
    String? startDate,
    String? endDate,
    String? riskTypeId,
  }) async {
    try {
      final response = await _getHeatmapUseCase.execute(
        northEastLat: northEast.latitude,
        northEastLon: northEast.longitude,
        southWestLat: southWest.latitude,
        southWestLon: southWest.longitude,
        startDate: startDate,
        endDate: endDate,
        riskTypeId: riskTypeId,
      );

      _heatmapPoints = response.points;
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Error loading heatmap: ${ErrorHandler.getUserFriendlyMessage(e)}');
    }
  }

  void clearRoute() {
    _status = RouteStatus.idle;
    _route = null;
    _heatmapPoints = [];
    _errorMessage = null;
    _selectedOrigin = null;
    _selectedDestination = null;
    notifyListeners();
  }

  void clearError() {
    _status = RouteStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
