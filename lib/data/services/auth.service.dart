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
  Future<UserProfile> login({required LoginRequestDTO user});
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
  Future<UserProfile> login({required LoginRequestDTO user}) async {
    try {
      log('Attempting login for: ${user.email}', name: 'AuthService');
      
      final response = await _httpClient.post(
        '/auth/login',
        data: user.toJson(),
      );

      log('Login response status: ${response.statusCode}', name: 'AuthService');
      log('Login response data type: ${response.data.runtimeType}', name: 'AuthService');

      if (response.statusCode == 200 && response.data != null) {
        log('Parsing login response...', name: 'AuthService');
        
        final loggedInUser = AuthTokenResponseDTO.fromJson(response.data);

        log('Login parsed successfully, saving to DB...', name: 'AuthService');
        
        await _dbHelper.setData(
          collection: BDCollections.USERS,
          key: 'user',
          value: loggedInUser.toJson(),
        );

        // 🔑 CRITICAL: Configurar token no AuthTokenManager para repositórios usarem
        log('🔑 [AuthService] Setting auth token in AuthTokenManager...', name: 'AuthService');
        log('🔑 [AuthService] Token received from backend (${loggedInUser.accessToken.length} chars)', 
            name: 'AuthService');
        log('🔑 [AuthService] Token format will be: Authorization: Bearer ${loggedInUser.accessToken.substring(0, 20)}...', 
            name: 'AuthService');
        
        AuthTokenManager().setToken(loggedInUser.accessToken);
        
        log('✅ [AuthService] Auth token configured successfully', name: 'AuthService');
        log('✅ [AuthService] Login successful for user: ${loggedInUser.user.email}', 
            name: 'AuthService');
        
        return UserProfile.fromAuthUserSummaryDTO(loggedInUser.user);
      } else {
        log('Login failed with status: ${response.statusCode}', name: 'AuthService');
        throw ServerException(
          message: 'Falha ao fazer login',
          statusCode: response.statusCode,
        );
      }
    } on HttpException catch (e) {
      log('HTTP Exception during login: ${e.message}', name: 'AuthService');
      rethrow;
    } catch (e, stackTrace) {
      log('Unexpected error during login: $e', name: 'AuthService');
      log('Stack trace: $stackTrace', name: 'AuthService');
      throw ServerException(message: 'Erro inesperado ao fazer login: $e');
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
  Future<bool> register({required RegisterRequestDTO registerDto}) async {
    try {
      final response = await _httpClient.post(
        '/auth/signup',
        data: registerDto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('Registration successful - user ID: ${response.data?['id']}', name: 'AuthService');
        return true;
      } else {
        throw ServerException(
          message: 'Falha ao registrar usuário',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error during registration: $e', name: 'AuthService');
      throw ServerException(message: 'Erro inesperado ao registrar');
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
        log('Password reset code sent successfully', name: 'AuthService');
        return true;
      } else {
        throw ServerException(
          message: 'Falha ao enviar código de recuperação',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error during password reset: $e', name: 'AuthService');
      throw ServerException(message: 'Erro inesperado ao resetar senha');
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
      log('Unexpected error during registration confirmation: $e', name: 'AuthService');
      throw ServerException(message: 'Erro inesperado ao confirmar cadastro');
    }
  }

  /// Reset password with code and new password
  Future<bool> confirmPasswordReset({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/auth/password/reset',
        data: {
          'email': email,
          'password': password,
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
      log('Unexpected error during password reset confirmation: $e', name: 'AuthService');
      throw ServerException(message: 'Erro inesperado ao resetar senha');
    }
  }
}
