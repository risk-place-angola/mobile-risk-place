import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:rpa/core/managers/permission_manager.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final permissionManager = PermissionManager();

      final serviceEnabled = await permissionManager.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled', name: 'LocationService');
        return null;
      }

      final hasPermission = await permissionManager.hasLocationPermission();
      if (!hasPermission) {
        log('Location permission not granted', name: 'LocationService');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      log('Location obtained: ${position.latitude}, ${position.longitude}',
          name: 'LocationService');
      return position;
    } catch (e) {
      log('Error getting location: $e', name: 'LocationService');
      return null;
    }
  }

  /// Get position stream for real-time location updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
