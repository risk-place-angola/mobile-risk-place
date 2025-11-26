import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/danger_zone_dto.dart';
import 'package:rpa/domain/entities/danger_zone.dart';

final dangerZoneServiceProvider = Provider<DangerZoneService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return DangerZoneService(httpClient: httpClient);
});

class DangerZoneService {
  final IHttpClient _httpClient;
  DateTime? _lastFetch;
  List<DangerZoneEntity>? _cachedZones;
  static const _cacheDuration = Duration(minutes: 30);

  DangerZoneService({required IHttpClient httpClient})
      : _httpClient = httpClient;

  Future<List<DangerZoneEntity>> getNearbyDangerZones({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheValid()) {
      log('[DangerZoneService] Returning cached zones');
      return _cachedZones!;
    }

    try {
      log('[DangerZoneService] Fetching danger zones from backend');

      final request = DangerZoneRequestDto(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );

      final response = await _httpClient.post(
        '/danger-zones/nearby',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch danger zones',
          statusCode: response.statusCode,
        );
      }

      final responseDto =
          DangerZoneResponseDto.fromJson(response.data as Map<String, dynamic>);

      _cachedZones = responseDto.toEntities();
      _lastFetch = DateTime.now();

      log('[DangerZoneService] Fetched ${_cachedZones!.length} danger zones');
      return _cachedZones!;
    } on HttpException {
      rethrow;
    } catch (e) {
      log('[DangerZoneService] Unexpected error: $e');
      throw ServerException(message: 'Failed to fetch danger zones');
    }
  }

  bool _isCacheValid() {
    if (_lastFetch == null || _cachedZones == null) return false;
    final elapsed = DateTime.now().difference(_lastFetch!);
    return elapsed < _cacheDuration;
  }

  void clearCache() {
    log('[DangerZoneService] Clearing danger zones cache');
    _lastFetch = null;
    _cachedZones = null;
  }
}
