import 'package:flutter/material.dart';

class AvatarUtils {
  static const int _totalAvatars = 21;
  static const int _hashMultiplier = 31;

  static const List<Color> _avatarColors = [
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

  static AvatarAssignment assignAvatar(String userId) {
    int hash = 0;
    for (int i = 0; i < userId.length; i++) {
      hash = hash * _hashMultiplier + userId.codeUnitAt(i);
    }

    if (hash < 0) {
      hash = -hash;
    }

    final avatarId = (hash % _totalAvatars) + 1;
    final colorIndex = hash % _avatarColors.length;
    final color = _avatarColors[colorIndex];

    return AvatarAssignment(avatarId: avatarId, color: color);
  }

  static String getAvatarPath(int avatarId) {
    return 'assets/avatars/avatar_$avatarId.svg';
  }
}

class AvatarAssignment {
  final int avatarId;
  final Color color;

  AvatarAssignment({required this.avatarId, required this.color});
}
