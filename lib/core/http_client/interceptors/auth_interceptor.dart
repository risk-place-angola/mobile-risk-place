import 'package:dio/dio.dart';
import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'dart:developer';

/// Singleton to manage auth token
class AuthTokenManager {
  static final AuthTokenManager _instance = AuthTokenManager._internal();
  factory AuthTokenManager() => _instance;
  AuthTokenManager._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
    log('Auth token set', name: 'AuthTokenManager');
  }

  String? getToken() => _token;

  void clearToken() {
    _token = null;
    log('Auth token cleared', name: 'AuthTokenManager');
  }
}

/// Interceptor to add authentication token to requests
class AuthInterceptor extends Interceptor {
  final IDBHelper _dbHelper;

  AuthInterceptor(this._dbHelper);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Get token from manager
      String? token = AuthTokenManager().getToken();
      
      // If no token in manager, try to get from database
      if (token == null || token.isEmpty) {
        final userData = await _dbHelper.getData(
          collection: BDCollections.USERS,
          key: 'user',
        );
        
        if (userData != null) {
          final userDataMap = Map<String, dynamic>.from(userData as Map);
          final authData = AuthTokenResponseDTO.fromJson(userDataMap);
          final dbToken = authData.accessToken;
          
          if (dbToken.isNotEmpty) {
            // Update manager with token from database
            AuthTokenManager().setToken(dbToken);
            token = dbToken;
            log('Token loaded from database for request: ${options.path}', 
                name: 'AuthInterceptor');
          }
        }
      }

      // Add token to request headers
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        log('Added auth token to request: ${options.path}', name: 'AuthInterceptor');
      }
    } catch (e) {
      log('Error adding auth token: $e', name: 'AuthInterceptor');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      log('Received 401 Unauthorized - clearing token', name: 'AuthInterceptor');
      
      // Clear token from manager
      AuthTokenManager().clearToken();
      
      // Clear user data from database
      try {
        await _dbHelper.deleteData(collection: BDCollections.USERS, key: 'user');
      } catch (e) {
        log('Error clearing user data: $e', name: 'AuthInterceptor');
      }
    }

    return handler.next(err);
  }
}
