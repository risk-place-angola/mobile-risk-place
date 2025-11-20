import 'package:flutter/material.dart';

class AvatarColors {
  static const List<Color> colors = [
    Color(0xFF4A90E2),
    Color(0xFFE94B3C),
    Color(0xFF50C878),
    Color(0xFFF5A623),
    Color(0xFF9B59B6),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFFFF9800),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFFFEB3B),
    Color(0xFF8BC34A),
    Color(0xFF673AB7),
    Color(0xFF009688),
    Color(0xFFFF5722),
  ];

  static Color getColorForUserId(String userId) {
    final hash = userId.hashCode.abs();
    return colors[hash % colors.length];
  }

  static Color getRandomColor() {
    return colors[(DateTime.now().millisecond) % colors.length];
  }
}
