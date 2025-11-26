import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  DateTime? _lastLocationCheck;
  DateTime? _lastNotificationCheck;
  LocationPermission? _cachedLocationPermission;
  AuthorizationStatus? _cachedNotificationStatus;

  static const _cacheDuration = Duration(minutes: 5);

  Future<LocationPermission> getLocationPermission(
      {bool forceCheck = false}) async {
    if (!forceCheck &&
        _cachedLocationPermission != null &&
        _lastLocationCheck != null &&
        DateTime.now().difference(_lastLocationCheck!) < _cacheDuration) {
      log('Using cached location permission: $_cachedLocationPermission',
          name: 'PermissionManager');
      return _cachedLocationPermission!;
    }

    _cachedLocationPermission = await Geolocator.checkPermission();
    _lastLocationCheck = DateTime.now();
    log('Location permission checked: $_cachedLocationPermission',
        name: 'PermissionManager');
    return _cachedLocationPermission!;
  }

  Future<bool> hasLocationPermission({bool forceCheck = false}) async {
    final permission = await getLocationPermission(forceCheck: forceCheck);
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<LocationPermission> requestLocationPermission() async {
    final currentPermission = await getLocationPermission(forceCheck: true);

    if (currentPermission == LocationPermission.always ||
        currentPermission == LocationPermission.whileInUse) {
      log('Location permission already granted', name: 'PermissionManager');
      return currentPermission;
    }

    if (currentPermission == LocationPermission.deniedForever) {
      log('Location permission denied forever', name: 'PermissionManager');
      return currentPermission;
    }

    log('Requesting location permission', name: 'PermissionManager');
    _cachedLocationPermission = await Geolocator.requestPermission();
    _lastLocationCheck = DateTime.now();

    log('Location permission result: $_cachedLocationPermission',
        name: 'PermissionManager');
    return _cachedLocationPermission!;
  }

  Future<AuthorizationStatus> getNotificationPermission(
      {bool forceCheck = false}) async {
    if (!forceCheck &&
        _cachedNotificationStatus != null &&
        _lastNotificationCheck != null &&
        DateTime.now().difference(_lastNotificationCheck!) < _cacheDuration) {
      log('Using cached notification permission: $_cachedNotificationStatus',
          name: 'PermissionManager');
      return _cachedNotificationStatus!;
    }

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    _cachedNotificationStatus = settings.authorizationStatus;
    _lastNotificationCheck = DateTime.now();

    log('Notification permission checked: $_cachedNotificationStatus',
        name: 'PermissionManager');
    return _cachedNotificationStatus!;
  }

  Future<bool> hasNotificationPermission({bool forceCheck = false}) async {
    final status = await getNotificationPermission(forceCheck: forceCheck);
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<AuthorizationStatus> requestNotificationPermission() async {
    final currentStatus = await getNotificationPermission(forceCheck: true);

    if (currentStatus == AuthorizationStatus.authorized ||
        currentStatus == AuthorizationStatus.provisional) {
      log('Notification permission already granted', name: 'PermissionManager');
      return currentStatus;
    }

    if (currentStatus == AuthorizationStatus.denied) {
      log('Notification permission previously denied',
          name: 'PermissionManager');
      return currentStatus;
    }

    log('Requesting notification permission', name: 'PermissionManager');
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    _cachedNotificationStatus = settings.authorizationStatus;
    _lastNotificationCheck = DateTime.now();

    log('Notification permission result: $_cachedNotificationStatus',
        name: 'PermissionManager');
    return _cachedNotificationStatus!;
  }

  void invalidateCache() {
    _cachedLocationPermission = null;
    _cachedNotificationStatus = null;
    _lastLocationCheck = null;
    _lastNotificationCheck = null;
    log('Permission cache invalidated', name: 'PermissionManager');
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
