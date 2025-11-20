class RouteWaypoint {
  final double latitude;
  final double longitude;
  final int sequence;

  const RouteWaypoint({
    required this.latitude,
    required this.longitude,
    required this.sequence,
  });

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) {
    return RouteWaypoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sequence: json['sequence'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteWaypoint &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          sequence == other.sequence;

  @override
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ sequence.hashCode;
}
