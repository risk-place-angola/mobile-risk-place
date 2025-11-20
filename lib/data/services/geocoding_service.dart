import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'package:http/http.dart' as http;
import 'package:rpa/data/models/place_search_result.dart';

/// Service for geocoding and address search using Nominatim (OpenStreetMap)
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // Cache for search results
  final Map<String, List<PlaceSearchResult>> _searchCache = {};
  Timer? _debounceTimer;

  /// Search for places with debouncing
  Future<List<PlaceSearchResult>> searchPlaces(
    String query, {
    String? countryCode,
    int limit = 10,
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache && _searchCache.containsKey(query)) {
      log('Returning cached results for: $query', name: 'GeocodingService');
      return _searchCache[query]!;
    }

    try {
      final params = {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': limit.toString(),
        'accept-language': 'pt,en',
      };

      if (countryCode != null) {
        params['countrycodes'] = countryCode;
      }

      final uri =
          Uri.parse('$_baseUrl/search').replace(queryParameters: params);

      log('Searching: $query', name: 'GeocodingService');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'RiskPlace-Mobile-App/1.0', // Required by Nominatim
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results = data
            .map((json) => PlaceSearchResult.fromNominatimJson(json))
            .toList();

        // Sort by importance
        results.sort((a, b) => b.importance.compareTo(a.importance));

        // Cache results
        _searchCache[query] = results;

        log('Found ${results.length} results for: $query',
            name: 'GeocodingService');
        return results;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      log('Search error: $e', name: 'GeocodingService');
      rethrow;
    }
  }

  /// Search with debouncing (waits for user to stop typing)
  Future<List<PlaceSearchResult>> searchWithDebounce(
    String query, {
    String? countryCode,
    int limit = 10,
    Function(List<PlaceSearchResult>)? onResults,
  }) {
    final completer = Completer<List<PlaceSearchResult>>();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      try {
        final results = await searchPlaces(
          query,
          countryCode: countryCode,
          limit: limit,
        );
        onResults?.call(results);
        completer.complete(results);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Reverse geocoding - get address from coordinates
  Future<PlaceSearchResult?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final params = {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
        'addressdetails': '1',
        'accept-language': 'pt,en',
      };

      final uri =
          Uri.parse('$_baseUrl/reverse').replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'RiskPlace-Mobile-App/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlaceSearchResult.fromNominatimJson(data);
      } else {
        return null;
      }
    } catch (e) {
      log('Reverse geocoding error: $e', name: 'GeocodingService');
      return null;
    }
  }

  /// Clear search cache
  void clearCache() {
    _searchCache.clear();
  }

  /// Cancel any pending debounce timers
  void dispose() {
    _debounceTimer?.cancel();
  }
}
