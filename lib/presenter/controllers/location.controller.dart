import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rpa/data/services/location.service.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/core/managers/location_history_manager.dart';
import 'package:rpa/core/managers/danger_zones_calculator.dart';
import 'package:rpa/core/managers/permission_manager.dart';

/// Location controller using ChangeNotifier
class LocationController extends ChangeNotifier {
  final LocationService _locationService;
  final AlertWebSocketService? _webSocketService;
  final LocationHistoryManager? _historyManager;
  final DangerZonesCalculator? _dangerZonesCalculator;
  StreamSubscription<Position>? _positionStreamSubscription;

  Position? _currentPosition;
  bool _isLoading = false;
  dynamic _error;
  bool _permissionGranted = false;
  DangerZone? _currentDangerZone;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  dynamic get error => _error;
  bool get permissionGranted => _permissionGranted;
  DangerZone? get currentDangerZone => _currentDangerZone;

  LocationController(
    this._locationService, {
    AlertWebSocketService? webSocketService,
    LocationHistoryManager? historyManager,
    DangerZonesCalculator? dangerZonesCalculator,
  })  : _webSocketService = webSocketService,
        _historyManager = historyManager,
        _dangerZonesCalculator = dangerZonesCalculator;

  /// Request location permission and get current position
  Future<bool> requestLocationPermission() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final permissionManager = PermissionManager();
      final permission = await permissionManager.requestLocationPermission();

      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        _isLoading = false;
        _permissionGranted = false;
        _error = Exception('Location permission denied');
        notifyListeners();
        return false;
      }

      _permissionGranted = true;
      notifyListeners();

      await getCurrentPosition();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e;
      notifyListeners();
      log('Error requesting permission: $e', name: 'LocationController');
      return false;
    }
  }

  /// Get current position once
  Future<void> getCurrentPosition() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Position? position = await _locationService.getCurrentPosition();

      if (position != null) {
        _currentPosition = position;
        _isLoading = false;
        _permissionGranted = true;
        notifyListeners();
        log('Position updated: ${position.latitude}, ${position.longitude}',
            name: 'LocationController');
      } else {
        _isLoading = false;
        _error = Exception('Não foi possível obter a localização');
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _error = e;
      notifyListeners();
      log('Error getting position: $e', name: 'LocationController');
    }
  }

  /// Start listening to position updates
  /// Automatically sends location updates to WebSocket for real-time alerts (Waze-like behavior)
  void startLocationUpdates() {
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = _locationService
        .getPositionStream(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1, // Update every 1 meter for maximum precision
    )
        .listen(
      (Position position) {
        _currentPosition = position;
        _permissionGranted = true;

        _historyManager?.addLocation(position);

        _currentDangerZone = _dangerZonesCalculator?.findNearestDangerZone(
          position.latitude,
          position.longitude,
        );

        notifyListeners();
        log('[LocationController] Position: ${position.latitude}, ${position.longitude}',
            name: 'LocationController');

        if (_webSocketService != null && _webSocketService!.isConnected) {
          _webSocketService!.updateLocation(
            position.latitude,
            position.longitude,
            speed: position.speed,
            heading: position.heading,
          );
          log('[LocationController] Location sent to WebSocket',
              name: 'LocationController');
        }

        if (_currentDangerZone != null) {
          log('[LocationController] In danger zone: ${_currentDangerZone!.incidentCount} incidents',
              name: 'LocationController');
        }
      },
      onError: (error) {
        _error = error;
        notifyListeners();
        log('Position stream error: $error', name: 'LocationController');
      },
    );
  }

  /// Stop listening to position updates
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for LocationService
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationControllerProvider =
    ChangeNotifierProvider<LocationController>((ref) {
  final locationService = ref.read(locationServiceProvider);
  final webSocketService = ref.read(alertWebSocketProvider);
  final historyManager = ref.read(locationHistoryManagerProvider);
  final dangerZonesCalculator = ref.read(dangerZonesCalculatorProvider);

  return LocationController(
    locationService,
    webSocketService: webSocketService,
    historyManager: historyManager,
    dangerZonesCalculator: dangerZonesCalculator,
  );
});
