import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/models/user_profile.dart';
import 'package:rpa/data/providers/repository_providers.dart';

final authServiceProvider = Provider<IAuthService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  final dbHelper = ref.read(dbHelperProvider);
  return AuthService(httpClient: httpClient, dbHelper: dbHelper);
});

abstract class IAuthService {
  Future<UserProfile> login({required LoginRequestDTO user, String? deviceId});
  Future<bool> logout();
  Future<EmailFallbackResponseDTO?> register(
      {required RegisterRequestDTO registerDto, String? deviceId});
  Future<EmailFallbackResponseDTO?> forgotPassword({required String identifier});
  Future<bool> verifyCode({required String identifier, required String code});
  Future<bool> resetPassword({required String identifier, required String code, required String password});
  Future<EmailFallbackResponseDTO?> resendVerificationCode({required String identifier});
  Future<AuthTokenResponseDTO> refreshToken({required String refreshToken});
}

class AuthService implements IAuthService {
  final IHttpClient _httpClient;
  final IDBHelper _dbHelper;

  AuthService({required IHttpClient httpClient, required IDBHelper dbHelper})
      : _httpClient = httpClient,
        _dbHelper = dbHelper;

  @override
  Future<UserProfile> login(
      {required LoginRequestDTO user, String? deviceId}) async {
    try {
      log('Attempting login for: ${user.identifier}', name: 'AuthService');

      final data = user.toJson();
      if (deviceId != null) {
        data['device_id'] = deviceId;
      }

      final response = await _httpClient.post(
        '/auth/login',
        data: data,
      );

      // Se chegou aqui, o status é 200 (sucesso)
      if (response.data == null) {
        throw ServerException(
          message: 'Empty response from server',
          statusCode: response.statusCode,
        );
      }

      final loggedInUser = AuthTokenResponseDTO.fromJson(response.data);

      await _dbHelper.setData(
        collection: BDCollections.USERS,
        key: 'user',
        value: loggedInUser.toJson(),
      );

      AuthTokenManager().setToken(
        loggedInUser.accessToken,
        refreshToken: loggedInUser.refreshToken,
        expiresIn: loggedInUser.expiresIn,
      );

      log('Login successful for user: ${loggedInUser.user.email}',
          name: 'AuthService');

      return UserProfile.fromAuthUserSummaryDTO(loggedInUser.user);
    } on HttpException catch (e) {
      log('HttpException caught in AuthService: ${e.runtimeType} - ${e.message}', name: 'AuthService');
      rethrow;
    } on FormatException catch (e) {
      log('Format error during login: ${e.message}', name: 'AuthService');
      throw HttpException(message: 'Invalid server response');
    } catch (e, stackTrace) {
      log('Unexpected error during login',
          name: 'AuthService', error: e, stackTrace: stackTrace);
      throw HttpException(message: 'Login error');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _dbHelper.deleteData(collection: BDCollections.USERS, key: '');

      // 🔑 Limpar token do AuthTokenManager
      log('Clearing auth token from AuthTokenManager...', name: 'AuthService');
      AuthTokenManager().clearToken();

      log('User logged out successfully', name: 'AuthService');
      return true;
    } catch (e) {
      log('Error during logout: $e', name: 'AuthService');
      rethrow;
    }
  }

  @override
  Future<EmailFallbackResponseDTO?> register(
      {required RegisterRequestDTO registerDto, String? deviceId}) async {
    try {
      final data = registerDto.toJson();
      if (deviceId != null) {
        data['device_id'] = deviceId;
      }

      final response = await _httpClient.post(
        '/auth/signup',
        data: data,
      );

      log('✅ Registration successful', name: 'AuthService');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final fallbackData = EmailFallbackResponseDTO.fromJson(response.data);
        if (fallbackData.isSentViaEmail) {
          log('Code sent via email fallback', name: 'AuthService');
          return fallbackData;
        }
      }

      return null;
    } on HttpException {
      rethrow;
    } catch (e, stackTrace) {
      log('❌ Unexpected error during registration',
          name: 'AuthService', error: e, stackTrace: stackTrace);
      throw HttpException(message: 'Erro ao registrar usuário');
    }
  }

  @override
  Future<EmailFallbackResponseDTO?> forgotPassword({required String identifier}) async {
    try {
      final response = await _httpClient.post(
        '/auth/password/forgot',
        data: {'identifier': identifier},
      );

      log('Password reset code sent', name: 'AuthService');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final fallbackData = EmailFallbackResponseDTO.fromJson(response.data);
        if (fallbackData.isSentViaEmail) {
          log('Password reset code sent via email fallback', name: 'AuthService');
          return fallbackData;
        }
      }

      return null;
    } on HttpException {
      rethrow;
    } catch (e, stackTrace) {
      log('Error during forgot password',
          name: 'AuthService', error: e, stackTrace: stackTrace);
      throw HttpException(message: 'Failed to send reset code');
    }
  }

  @override
  Future<bool> verifyCode({
    required String identifier,
    required String code,
  }) async {
    try {
      await _httpClient.post(
        '/auth/confirm',
        data: {
          'identifier': identifier,
          'code': code,
        },
      );

      // If we get here, request was successful (200-299)
      log('Code verified successfully', name: 'AuthService');
      return true;
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Error during code verification: $e', name: 'AuthService');
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword({
    required String identifier,
    required String code,
    required String password,
  }) async {
    try {
      await _httpClient.post(
        '/auth/password/reset',
        data: {
          'identifier': identifier,
          'code': code,
          'password': password,
        },
      );

      log('Password reset successfully', name: 'AuthService');
      return true;
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Error during password reset: $e', name: 'AuthService');
      throw ServerException(message: 'Failed to reset password');
    }
  }

  @override
  Future<EmailFallbackResponseDTO?> resendVerificationCode({required String identifier}) async {
    try {
      final response = await _httpClient.post(
        '/auth/resend-code',
        data: {'identifier': identifier},
      );

      log('Verification code resent', name: 'AuthService');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final fallbackData = EmailFallbackResponseDTO.fromJson(response.data);
        if (fallbackData.isSentViaEmail) {
          log('Verification code sent via email fallback', name: 'AuthService');
          return fallbackData;
        }
      }

      return null;
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Error resending verification code: $e', name: 'AuthService');
      throw ServerException(message: 'Failed to resend code');
    }
  }

  @override
  Future<AuthTokenResponseDTO> refreshToken(
      {required String refreshToken}) async {
    try {
      log('Attempting token refresh', name: 'AuthService');

      final response = await _httpClient.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(
          message: 'Empty response from server',
          statusCode: response.statusCode,
        );
      }

      final tokenResponse = AuthTokenResponseDTO.fromJson(response.data);

      await _dbHelper.setData(
        collection: BDCollections.USERS,
        key: 'user',
        value: tokenResponse.toJson(),
      );

      AuthTokenManager().setToken(
        tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiresIn: tokenResponse.expiresIn,
      );

      log('✅ Token refreshed successfully', name: 'AuthService');

      return tokenResponse;
    } on HttpException {
      rethrow;
    } catch (e, stackTrace) {
      log('❌ Unexpected error during token refresh',
          name: 'AuthService', error: e, stackTrace: stackTrace);
      throw HttpException(message: 'Failed to refresh authentication token');
    }
  }
}
