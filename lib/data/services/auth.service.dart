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
  Future<bool> register(
      {required RegisterRequestDTO registerDto, String? deviceId});
  Future<bool> resetPassword({required String email});
  Future<bool> confirmPasswordReset(
      {required String email,
      required String code,
      required String newPassword});
  Future<bool> resendVerificationCode({required String email});
  Future<bool> confirmRegistration(
      {required String email, required String code});
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
      log('Attempting login for: ${user.email}', name: 'AuthService');

      final data = user.toJson();
      if (deviceId != null) {
        data['device_id'] = deviceId;
      }

      final response = await _httpClient.post(
        '/auth/login',
        data: data,
      );

      if (response.statusCode != 200 || response.data == null) {
        throw ServerException(
          message: 'Falha ao fazer login',
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

      log('✅ Login successful for user: ${loggedInUser.user.email}',
          name: 'AuthService');

      return UserProfile.fromAuthUserSummaryDTO(loggedInUser.user);
    } on HttpException {
      rethrow;
    } on FormatException catch (e) {
      log('❌ Format error during login: ${e.message}', name: 'AuthService');
      throw HttpException(message: 'Erro ao processar resposta do servidor');
    } catch (e, stackTrace) {
      log('❌ Unexpected error during login',
          name: 'AuthService', error: e, stackTrace: stackTrace);
      throw HttpException(message: 'Erro ao realizar login');
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
  Future<bool> register(
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ Registration successful', name: 'AuthService');
        return true;
      }

      throw ServerException(
        message: 'Falha ao registrar usuário',
        statusCode: response.statusCode,
      );
    } on HttpException {
      rethrow;
    } catch (e, stackTrace) {
      log('❌ Unexpected error during registration',
          name: 'AuthService', error: e, stackTrace: stackTrace);
      throw HttpException(message: 'Erro ao registrar usuário');
    }
  }

  @override
  Future<bool> resetPassword({required String email}) async {
    try {
      final response = await _httpClient.post(
        '/auth/password/forgot',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        log('✅ Password reset code sent successfully', name: 'AuthService');
        return true;
      }

      throw ServerException(
        message: 'Falha ao enviar código de recuperação',
        statusCode: response.statusCode,
      );
    } on HttpException {
      rethrow;
    } catch (e, stackTrace) {
      log('❌ Unexpected error during password reset',
          name: 'AuthService', error: e, stackTrace: stackTrace);
      throw HttpException(message: 'Erro ao resetar senha');
    }
  }

  /// Confirm user registration with verification code
  Future<bool> confirmRegistration({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _httpClient.post(
        '/auth/confirm',
        data: {
          'email': email,
          'code': code,
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        log('Registration confirmed successfully', name: 'AuthService');
        return true;
      } else {
        throw ServerException(
          message: 'Falha ao confirmar cadastro',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error during registration confirmation: $e',
          name: 'AuthService');
      throw ServerException(message: 'Erro inesperado ao confirmar cadastro');
    }
  }

  @override
  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _httpClient.post(
        '/auth/password/reset',
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        log('Password reset successfully', name: 'AuthService');
        return true;
      } else {
        throw ServerException(
          message: 'Falha ao resetar senha',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error during password reset confirmation: $e',
          name: 'AuthService');
      throw ServerException(message: 'Erro inesperado ao resetar senha');
    }
  }

  @override
  Future<bool> resendVerificationCode({required String email}) async {
    try {
      final response = await _httpClient.post(
        '/auth/resend-code',
        data: {'email': email},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        log('✅ Verification code resent successfully', name: 'AuthService');
        return true;
      }

      throw ServerException(
        message: 'Falha ao reenviar código de verificação',
        statusCode: response.statusCode,
      );
    } on HttpException {
      rethrow;
    } catch (e) {
      log('❌ Error resending verification code: $e', name: 'AuthService');
      throw ServerException(message: 'Erro ao reenviar código de verificação');
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

      if (response.statusCode != 200 || response.data == null) {
        throw ServerException(
          message: 'Failed to refresh token',
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
