import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/services/i_profile_service.dart';
import 'package:rpa/data/models/saved_address.dart';
import 'package:rpa/data/dtos/update_profile_request_dto.dart';
import 'package:rpa/data/dtos/navigate_request_dto.dart';
import 'package:rpa/data/dtos/safe_route_response_dto.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return ProfileService(httpClient: httpClient);
});

class ProfileService implements IProfileService {
  final IHttpClient _httpClient;

  SavedAddress? _cachedHomeAddress;
  SavedAddress? _cachedWorkAddress;

  ProfileService({required IHttpClient httpClient}) : _httpClient = httpClient;

  @override
  Future<void> updateProfile({
    SavedAddress? homeAddress,
    SavedAddress? workAddress,
  }) async {
    try {
      log('Updating profile with addresses...', name: 'ProfileService');

      final request = UpdateProfileRequestDTO(
        homeAddress: homeAddress,
        workAddress: workAddress,
      );

      await _httpClient.put(
        '/users/profile',
        data: request.toJson(),
      );

      // If we get here, request was successful (200-299)
      log('Profile updated successfully', name: 'ProfileService');
      if (homeAddress != null) _cachedHomeAddress = homeAddress;
      if (workAddress != null) _cachedWorkAddress = workAddress;
    } catch (e) {
      log('Error updating profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  @override
  Future<SavedAddress?> getHomeAddress() async {
    if (_cachedHomeAddress != null) return _cachedHomeAddress;

    try {
      log('Fetching home address...', name: 'ProfileService');

      final response = await _httpClient.get('/users/profile');

      // If we get here, request was successful (200-299)
      if (response.data != null) {
        final homeData = response.data['home_address'];
        if (homeData != null) {
          _cachedHomeAddress = SavedAddress.fromJson(homeData);
          return _cachedHomeAddress;
        }
      }
      return null;
    } catch (e) {
      log('Error fetching home address: $e', name: 'ProfileService');
      return null;
    }
  }

  @override
  Future<SavedAddress?> getWorkAddress() async {
    if (_cachedWorkAddress != null) return _cachedWorkAddress;

    try {
      log('Fetching work address...', name: 'ProfileService');

      final response = await _httpClient.get('/users/profile');

      // If we get here, request was successful (200-299)
      if (response.data != null) {
        final workData = response.data['work_address'];
        if (workData != null) {
          _cachedWorkAddress = SavedAddress.fromJson(workData);
          return _cachedWorkAddress;
        }
      }
      return null;
    } catch (e) {
      log('Error fetching work address: $e', name: 'ProfileService');
      return null;
    }
  }

  @override
  Future<SafeRouteResponseDTO> navigateToHome({
    required double currentLat,
    required double currentLon,
  }) async {
    try {
      log('Navigating to home...', name: 'ProfileService');

      final request = NavigateRequestDTO(
        currentLat: currentLat,
        currentLon: currentLon,
      );

      final response = await _httpClient.post(
        '/routes/navigate-home',
        data: request.toJson(),
      );

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }
      
      log('Home route calculated successfully', name: 'ProfileService');
      return SafeRouteResponseDTO.fromJson(response.data);
    } catch (e) {
      log('Error navigating to home: $e', name: 'ProfileService');
      rethrow;
    }
  }

  @override
  Future<SafeRouteResponseDTO> navigateToWork({
    required double currentLat,
    required double currentLon,
  }) async {
    try {
      log('Navigating to work...', name: 'ProfileService');

      final request = NavigateRequestDTO(
        currentLat: currentLat,
        currentLon: currentLon,
      );

      final response = await _httpClient.post(
        '/routes/navigate-work',
        data: request.toJson(),
      );

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }
      
      log('Work route calculated successfully', name: 'ProfileService');
      return SafeRouteResponseDTO.fromJson(response.data);
    } catch (e) {
      log('Error navigating to work: $e', name: 'ProfileService');
      rethrow;
    }
  }
}
