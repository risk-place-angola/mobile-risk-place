import 'package:rpa/data/models/heatmap_point.dart';

class HeatmapBoundsInfo {
  final double northEastLat;
  final double northEastLon;
  final double southWestLat;
  final double southWestLon;

  const HeatmapBoundsInfo({
    required this.northEastLat,
    required this.northEastLon,
    required this.southWestLat,
    required this.southWestLon,
  });

  factory HeatmapBoundsInfo.fromJson(Map<String, dynamic> json) {
    return HeatmapBoundsInfo(
      northEastLat: (json['north_east_lat'] as num).toDouble(),
      northEastLon: (json['north_east_lon'] as num).toDouble(),
      southWestLat: (json['south_west_lat'] as num).toDouble(),
      southWestLon: (json['south_west_lon'] as num).toDouble(),
    );
  }
}

class HeatmapResponseDTO {
  final List<HeatmapPoint> points;
  final int totalCount;
  final HeatmapBoundsInfo boundsInfo;

  const HeatmapResponseDTO({
    required this.points,
    required this.totalCount,
    required this.boundsInfo,
  });

  factory HeatmapResponseDTO.fromJson(Map<String, dynamic> json) {
    return HeatmapResponseDTO(
      points: (json['points'] as List)
          .map((p) => HeatmapPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      boundsInfo: HeatmapBoundsInfo.fromJson(
        json['bounds_info'] as Map<String, dynamic>,
      ),
    );
  }
}
