import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/models/user_profile.dart';

final authServiceProvider = Provider<IAuthService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  final dbHelper = ref.read(dbHelperProvider);
  return AuthService(httpClient: httpClient, dbHelper: dbHelper);
});

abstract class IAuthService {
  Future<UserProfile?> login({required LoginRequestDTO user});
  Future<bool> logout();
  Future<bool> register({required RegisterRequestDTO registerDto});
  Future<bool> resetPassword({required String email});
}

class AuthService implements IAuthService {
  final IHttpClient _httpClient;
  final IDBHelper _dbHelper;

  AuthService({required IHttpClient httpClient, required IDBHelper dbHelper})
      : _httpClient = httpClient,
        _dbHelper = dbHelper;

  @override
  Future<UserProfile?> login({required LoginRequestDTO user}) async {
    try {
      final response = await _httpClient.post(
        '/login',
        body: user.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final loggedInUser = UserProfile.fromJson(data);

        await _dbHelper.setData(
          collection: BDCollections.USERS,
          value: loggedInUser.toJson(),
        );

        return loggedInUser;
      } else {
        log('Failed to login: ${response.statusMessage}', name: 'AuthService');
        throw Exception('Failed to login: ${response.statusMessage}');
      }
    } catch (e) {
      log('Error during login: $e', name: 'AuthService');
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _dbHelper.deleteData(collection: BDCollections.USERS);
      log('User logged out successfully', name: 'AuthService');
      return true;
    } catch (e) {
      log('Error during logout: $e', name: 'AuthService');
      rethrow;
    }
  }

  @override
  Future<bool> register({required RegisterRequestDTO registerDto}) async {
    try {
      final response = await _httpClient.post(
        '/register',
        body: registerDto.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        log('Failed to register: ${response.statusMessage}',
            name: 'AuthService');
        throw Exception('Failed to register: ${response.statusMessage}');
      }
    } catch (e) {
      log('Error during registration: $e', name: 'AuthService');
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword({required String email}) async {
    try {
      await _httpClient.post(
        '/reset-password',
        body: {'email': email},
      );
      log('Password reset email sent successfully', name: 'AuthService');
      return true;
    } catch (e) {
      log('Error during password reset: $e', name: 'AuthService');
      rethrow;
    }
  }
}
