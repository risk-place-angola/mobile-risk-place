import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/dtos/device_dto.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';

final deviceServiceProvider = Provider<DeviceService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return DeviceService(httpClient);
});

class DeviceService {
  final IHttpClient _httpClient;

  DeviceService(this._httpClient);

  Future<DeviceRegisterResponseDTO> registerDevice({
    required DeviceRegisterRequestDTO request,
  }) async {
    try {
      log('📡 Registering device: ${request.deviceId}', name: 'DeviceService');

      final response = await _httpClient.post(
        '/devices/register',
        data: request.toJson(),
      );

      log('✅ Device registered successfully', name: 'DeviceService');
      return DeviceRegisterResponseDTO.fromJson(response.data);
    } catch (e) {
      log('❌ Error registering device: $e', name: 'DeviceService');
      rethrow;
    }
  }

  Future<void> updateLocation({
    required UpdateDeviceLocationDTO request,
  }) async {
    try {
      await _httpClient.put(
        '/devices/location',
        data: request.toJson(),
      );

      log('✅ Location updated', name: 'DeviceService');
    } catch (e) {
      log('❌ Error updating location: $e', name: 'DeviceService');
      rethrow;
    }
  }
}
