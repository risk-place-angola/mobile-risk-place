import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rpa/data/services/location.service.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/core/error/error_handler.dart';

/// Location controller using ChangeNotifier
class LocationController extends ChangeNotifier {
  final LocationService _locationService;
  final AlertWebSocketService? _webSocketService;
  StreamSubscription<Position>? _positionStreamSubscription;

  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _permissionGranted = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get permissionGranted => _permissionGranted;

  LocationController(this._locationService,
      {AlertWebSocketService? webSocketService})
      : _webSocketService = webSocketService;

  /// Request location permission and get current position
  Future<bool> requestLocationPermission() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool hasPermission = await _locationService.handleLocationPermission();

      if (!hasPermission) {
        _isLoading = false;
        _permissionGranted = false;
        _errorMessage = 'Permissão de localização negada';
        notifyListeners();
        return false;
      }

      _permissionGranted = true;
      notifyListeners();

      // Get initial position after permission granted
      await getCurrentPosition();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      notifyListeners();
      log('Error requesting permission: $e', name: 'LocationController');
      return false;
    }
  }

  /// Get current position once
  Future<void> getCurrentPosition() async {
    _isLoading = true;
    _errorMessage = null;
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
        _errorMessage = 'Não foi possível obter a localização';
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
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
        notifyListeners();
        log('[LocationController] Position stream updated: ${position.latitude}, ${position.longitude}',
            name: 'LocationController');

        // 🌐 Send location update to WebSocket for real-time alerts (like Waze)
        // This ensures the backend knows the user's current position to send relevant alerts
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
      },
      onError: (error) {
        _errorMessage = 'Erro no stream de localização: $error';
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

/// Provider for LocationController with WebSocket integration
final locationControllerProvider =
    ChangeNotifierProvider<LocationController>((ref) {
  final locationService = ref.read(locationServiceProvider);
  final webSocketService = ref.read(alertWebSocketProvider);
  return LocationController(locationService,
      webSocketService: webSocketService);
});
