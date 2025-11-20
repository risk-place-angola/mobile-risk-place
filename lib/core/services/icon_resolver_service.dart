import 'package:flutter/material.dart';

class IconResolverService {
  static const String _assetBasePath = 'assets/icons';
  static const String _topicBasePath = 'assets/icons/topics';
  static const IconData _defaultIcon = Icons.warning_rounded;

  static const Map<String, String> _typeIconMap = {
    'violence': 'violence.png',
    'traffic': 'traffic.png',
    'urban_issue': 'urban_issue.png',
    'public_safety': 'public_safety.png',
    'health': 'health.png',
    'crime': 'crime.png',
    'environment': 'environment.png',
    'infrastructure': 'infrastructure.png',
    'accident': 'accident.png',
    'natural_disaster': 'natural_disaster.png',
    'fire': 'fire.png',
  };

  static ImageProvider? _resolveIcon(String name, String? apiIconUrl, bool isTopic) {
    if (apiIconUrl != null && apiIconUrl.isNotEmpty) {
      if (apiIconUrl.startsWith('http')) {
        return NetworkImage(apiIconUrl);
      }
    }

    final normalized = name.toLowerCase().trim().replaceAll(' ', '_');
    
    if (isTopic) {
      return AssetImage('$_topicBasePath/$normalized.png');
    } else {
      final localPath = _typeIconMap[normalized];
      if (localPath != null) {
        return AssetImage('$_assetBasePath/$localPath');
      }
    }

    return null;
  }

  static IconData getDefaultIcon() => _defaultIcon;

  static Widget buildIcon({
    required String typeName,
    String? apiIconPath,
    double size = 24,
    Color? color,
    bool isTopic = false,
  }) {
    final imageProvider = _resolveIcon(typeName, apiIconPath, isTopic);

    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(_defaultIcon, size: size, color: color);
        },
      );
    }

    return Icon(_defaultIcon, size: size, color: color);
  }
}
