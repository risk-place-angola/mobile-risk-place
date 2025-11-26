import 'dart:developer';
import 'dart:collection';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/managers/settings_manager.dart';

final locationHistoryManagerProvider = Provider<LocationHistoryManager>((ref) {
  final settingsManager = ref.watch(settingsManagerProvider);
  return LocationHistoryManager(settingsManager);
});

class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? heading;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.heading,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        if (speed != null) 'speed': speed,
        if (heading != null) 'heading': heading,
      };
}

class LocationHistoryManager {
  final SettingsManager _settingsManager;
  final Queue<LocationPoint> _history = Queue();
  static const int _maxHistorySize = 1000;
  static const int _batchSize = 50;

  LocationHistoryManager(this._settingsManager);

  void addLocation(Position position) {
    if (!_settingsManager.isLocationHistoryEnabled) {
      return;
    }

    final point = LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      speed: position.speed,
      heading: position.heading,
    );

    _history.addLast(point);

    if (_history.length > _maxHistorySize) {
      _history.removeFirst();
    }

    if (_history.length >= _batchSize) {
      _shouldFlushToBackend();
    }
  }

  void _shouldFlushToBackend() {
    log('History batch ready: ${_history.length} points',
        name: 'LocationHistoryManager');
  }

  List<LocationPoint> getHistory({int? limit}) {
    if (limit == null) {
      return _history.toList();
    }
    return _history.toList().sublist(
          (_history.length - limit).clamp(0, _history.length),
          _history.length,
        );
  }

  List<LocationPoint> getHistoryInTimeRange(DateTime start, DateTime end) {
    return _history
        .where((point) =>
            point.timestamp.isAfter(start) && point.timestamp.isBefore(end))
        .toList();
  }

  void clear() {
    _history.clear();
    log('Location history cleared', name: 'LocationHistoryManager');
  }

  int get historyCount => _history.length;

  bool get isEnabled => _settingsManager.isLocationHistoryEnabled;
}
