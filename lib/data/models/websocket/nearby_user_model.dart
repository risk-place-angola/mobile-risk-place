import 'package:flutter/material.dart';

class NearbyUserModel {
  final String userId;
  final double latitude;
  final double longitude;
  final String avatarId;
  final Color color;
  final DateTime lastUpdate;
  final double? heading;
  final double? speed;

  const NearbyUserModel({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.avatarId,
    required this.color,
    required this.lastUpdate,
    this.heading,
    this.speed,
  });

  factory NearbyUserModel.fromJson(Map<String, dynamic> json) {
    return NearbyUserModel(
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      avatarId: json['avatar_id'] as String,
      color: _parseColor(json['color'] as String),
      lastUpdate: DateTime.now(),
      heading: json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
    );
  }

  static Color _parseColor(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  bool get isInactive {
    return DateTime.now().difference(lastUpdate).inSeconds > 10;
  }

  NearbyUserModel copyWith({
    String? userId,
    double? latitude,
    double? longitude,
    String? avatarId,
    Color? color,
    DateTime? lastUpdate,
    double? heading,
    double? speed,
  }) {
    return NearbyUserModel(
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      avatarId: avatarId ?? this.avatarId,
      color: color ?? this.color,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
    );
  }
}
