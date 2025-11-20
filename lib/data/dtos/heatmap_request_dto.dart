class HeatmapRequestDTO {
  final double northEastLat;
  final double northEastLon;
  final double southWestLat;
  final double southWestLon;
  final String? startDate;
  final String? endDate;
  final String? riskTypeId;

  const HeatmapRequestDTO({
    required this.northEastLat,
    required this.northEastLon,
    required this.southWestLat,
    required this.southWestLon,
    this.startDate,
    this.endDate,
    this.riskTypeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'north_east_lat': northEastLat,
      'north_east_lon': northEastLon,
      'south_west_lat': southWestLat,
      'south_west_lon': southWestLon,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (riskTypeId != null && riskTypeId!.isNotEmpty)
        'risk_type_id': riskTypeId,
    };
  }
}
