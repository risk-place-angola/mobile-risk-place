class RiskIcons {
  static String? getIconUrl(String? iconUrl, String baseUrl) {
    if (iconUrl == null || iconUrl.isEmpty) return null;
    if (iconUrl.startsWith('http')) return iconUrl;
    return '$baseUrl$iconUrl';
  }

  static String getLocalIconForRiskType(String riskType) {
    return 'assets/icons/${riskType.toLowerCase()}.png';
  }

  static String getLocalIconForRiskTopic(String topicKey) {
    return 'assets/icons/topics/${topicKey.toLowerCase()}.png';
  }

  static String getIconForReportType(String reportId) {
    final normalized = reportId.toLowerCase();
    switch (normalized) {
      case 'fire':
        return 'assets/icons/fire.png';
      case 'police':
      case 'crime':
        return 'assets/icons/crime.png';
      case 'crash':
      case 'traffic':
        return 'assets/icons/accident.png';
      case 'hazard':
        return 'assets/icons/road_hazard.png';
      case 'closure':
      case 'blocked_lane':
        return 'assets/icons/road_block.png';
      case 'bad_weather':
      case 'flood':
        return 'assets/icons/natural_disaster.png';
      case 'roadside_help':
        return 'assets/icons/medical.png';
      default:
        return 'assets/icons/road_hazard.png';
    }
  }
}
