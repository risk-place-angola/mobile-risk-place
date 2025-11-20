class CalculateSafeRouteRequestDTO {
  final double originLat;
  final double originLon;
  final double destinationLat;
  final double destinationLon;
  final int maxRoutes;

  const CalculateSafeRouteRequestDTO({
    required this.originLat,
    required this.originLon,
    required this.destinationLat,
    required this.destinationLon,
    this.maxRoutes = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin_lat': originLat,
      'origin_lon': originLon,
      'destination_lat': destinationLat,
      'destination_lon': destinationLon,
      'max_routes': maxRoutes,
    };
  }
}
