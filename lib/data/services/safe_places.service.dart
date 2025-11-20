import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:rpa/data/models/safe_place.model.dart';

const String _safePlacesBoxName = 'safe_places';

abstract class ISafePlacesService {
  Future<void> initialize();
  Future<List<SafePlace>> getAllSafePlaces();
  Future<SafePlace?> getSafePlaceById(String id);
  Future<List<SafePlace>> getSafePlacesByCategory(SafePlaceCategory category);
  Future<SafePlace> createSafePlace(SafePlace place);
  Future<SafePlace> updateSafePlace(SafePlace place);
  Future<void> deleteSafePlace(String id);
  Future<void> deleteAllSafePlaces();
}

class SafePlacesService implements ISafePlacesService {
  Box<SafePlace>? _box;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<SafePlace>(_safePlacesBoxName);
    }
  }

  Box<SafePlace> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
          'SafePlacesService not initialized. Call initialize() first.');
    }
    return _box!;
  }

  @override
  Future<List<SafePlace>> getAllSafePlaces() async {
    return _safeBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<SafePlace?> getSafePlaceById(String id) async {
    return _safeBox.get(id);
  }

  @override
  Future<List<SafePlace>> getSafePlacesByCategory(
    SafePlaceCategory category,
  ) async {
    return _safeBox.values.where((place) => place.category == category).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<SafePlace> createSafePlace(SafePlace place) async {
    final newPlace = SafePlace(
      id: _uuid.v4(),
      name: place.name,
      description: place.description,
      latitude: place.latitude,
      longitude: place.longitude,
      category: place.category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _safeBox.put(newPlace.id, newPlace);
    return newPlace;
  }

  @override
  Future<SafePlace> updateSafePlace(SafePlace place) async {
    final existing = await getSafePlaceById(place.id);
    if (existing == null) {
      throw Exception('Safe place not found: ${place.id}');
    }

    final updated = place.copyWith();
    await _safeBox.put(updated.id, updated);
    return updated;
  }

  @override
  Future<void> deleteSafePlace(String id) async {
    await _safeBox.delete(id);
  }

  @override
  Future<void> deleteAllSafePlaces() async {
    await _safeBox.clear();
  }
}

final safePlacesServiceProvider = Provider<ISafePlacesService>((ref) {
  return SafePlacesService();
});
