import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'safe_place.model.g.dart';

@HiveType(typeId: 2)
class SafePlace extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final SafePlaceCategory category;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  SafePlace({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  SafePlace copyWith({
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    SafePlaceCategory? category,
  }) {
    return SafePlace(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'category': category.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory SafePlace.fromJson(Map<String, dynamic> json) => SafePlace(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        category: SafePlaceCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => SafePlaceCategory.other,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

@HiveType(typeId: 3)
enum SafePlaceCategory {
  @HiveField(0)
  home,

  @HiveField(1)
  work,

  @HiveField(2)
  policeStation,

  @HiveField(3)
  hospital,

  @HiveField(4)
  fireStation,

  @HiveField(5)
  family,

  @HiveField(6)
  friend,

  @HiveField(7)
  other,
}

extension SafePlaceCategoryExtension on SafePlaceCategory {
  String get displayName {
    switch (this) {
      case SafePlaceCategory.home:
        return 'Casa';
      case SafePlaceCategory.work:
        return 'Trabalho';
      case SafePlaceCategory.policeStation:
        return 'Delegacia';
      case SafePlaceCategory.hospital:
        return 'Hospital';
      case SafePlaceCategory.fireStation:
        return 'Bombeiros';
      case SafePlaceCategory.family:
        return 'Familiar';
      case SafePlaceCategory.friend:
        return 'Amigo';
      case SafePlaceCategory.other:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case SafePlaceCategory.home:
        return '🏠';
      case SafePlaceCategory.work:
        return '💼';
      case SafePlaceCategory.policeStation:
        return '👮';
      case SafePlaceCategory.hospital:
        return '🏥';
      case SafePlaceCategory.fireStation:
        return '🚒';
      case SafePlaceCategory.family:
        return '👨‍👩‍👧‍👦';
      case SafePlaceCategory.friend:
        return '👥';
      case SafePlaceCategory.other:
        return '📍';
    }
  }
}
