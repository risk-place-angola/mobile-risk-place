import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/data/models/location_sharing.model.dart';

abstract class ILocationSharingService {
  Future<LocationSharingSession> createSession({
    required int durationMinutes,
    required double latitude,
    required double longitude,
  });

  Future<void> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
  });

  Future<void> stopSharing(String sessionId);

  Future<PublicLocationView?> getPublicLocation(String token);
}

class LocationSharingService implements ILocationSharingService {
  final IHttpClient _httpClient;

  LocationSharingService(this._httpClient);

  @override
  Future<LocationSharingSession> createSession({
    required int durationMinutes,
    required double latitude,
    required double longitude,
  }) async {
    final request = LocationSharingRequest(
      durationMinutes: durationMinutes,
      latitude: latitude,
      longitude: longitude,
    );

    final response = await _httpClient.post(
      '/location-sharing',
      data: request.toJson(),
    );

    return LocationSharingSession.fromJson(response.data);
  }

  @override
  Future<void> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) async {
    final request = LocationUpdateRequest(
      latitude: latitude,
      longitude: longitude,
    );

    await _httpClient.put(
      '/location-sharing/$sessionId/location',
      data: request.toJson(),
    );
  }

  @override
  Future<void> stopSharing(String sessionId) async {
    await _httpClient.delete('/location-sharing/$sessionId');
  }

  @override
  Future<PublicLocationView?> getPublicLocation(String token) async {
    try {
      final response = await _httpClient.get('/share/$token');
      return PublicLocationView.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}

final locationSharingServiceProvider = Provider<ILocationSharingService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return LocationSharingService(httpClient);
});
