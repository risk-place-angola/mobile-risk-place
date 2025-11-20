import 'package:rpa/data/models/safe_route.dart';

class SafeRouteResponseDTO {
  final SafeRoute route;

  const SafeRouteResponseDTO({required this.route});

  factory SafeRouteResponseDTO.fromJson(Map<String, dynamic> json) {
    return SafeRouteResponseDTO(
      route: SafeRoute.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return route.toJson();
  }
}
