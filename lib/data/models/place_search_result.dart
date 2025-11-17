import 'package:latlong2/latlong.dart';

/// Place search result from geocoding
class PlaceSearchResult {
  final String placeId;
  final String displayName;
  final String name;
  final String? street;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? country;
  final LatLng location;
  final String type;
  final double importance;

  PlaceSearchResult({
    required this.placeId,
    required this.displayName,
    required this.name,
    this.street,
    this.neighborhood,
    this.city,
    this.state,
    this.country,
    required this.location,
    required this.type,
    required this.importance,
  });

  factory PlaceSearchResult.fromNominatimJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    
    return PlaceSearchResult(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] ?? '',
      name: json['name'] ?? json['display_name'] ?? '',
      street: address?['road'] ?? address?['street'],
      neighborhood: address?['neighbourhood'] ?? address?['suburb'],
      city: address?['city'] ?? address?['town'] ?? address?['village'],
      state: address?['state'],
      country: address?['country'],
      location: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
      type: json['type'] ?? 'unknown',
      importance: double.tryParse(json['importance']?.toString() ?? '0') ?? 0,
    );
  }

  String get shortAddress {
    final parts = <String>[];
    if (street != null) parts.add(street!);
    if (neighborhood != null) parts.add(neighborhood!);
    if (city != null) parts.add(city!);
    return parts.isEmpty ? displayName : parts.join(', ');
  }
}
