class NavigateRequestDTO {
  final double currentLat;
  final double currentLon;

  const NavigateRequestDTO({
    required this.currentLat,
    required this.currentLon,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_lat': currentLat,
      'current_lon': currentLon,
    };
  }
}
