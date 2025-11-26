import 'package:dio/dio.dart';
import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/core/device/device_id_manager.dart';
import 'dart:developer';

class AuthTokenManager {
  static final AuthTokenManager _instance = AuthTokenManager._internal();
  factory AuthTokenManager() => _instance;
  AuthTokenManager._internal();

  String? _token;
  String? _refreshToken;
  int? _expiresAt;

  void setToken(String token, {String? refreshToken, int? expiresIn}) {
    _token = token;
    _refreshToken = refreshToken;

    if (expiresIn != null) {
      _expiresAt = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    }

    log('Auth token set', name: 'AuthTokenManager');
  }

  String? getToken() => _token;

  String? getRefreshToken() => _refreshToken;

  bool isTokenExpired() {
    if (_expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= _expiresAt!;
  }

  bool shouldRefresh() {
    if (_expiresAt == null) return false;
    final timeUntilExpiry = _expiresAt! - DateTime.now().millisecondsSinceEpoch;
    return timeUntilExpiry < 300000;
  }

  void clearToken() {
    _token = null;
    _refreshToken = null;
    _expiresAt = null;
    log('Auth token cleared', name: 'AuthTokenManager');
  }
}

/// Interceptor to add authentication token to requests
class AuthInterceptor extends Interceptor {
  final IDBHelper _dbHelper;
  final DeviceIdManager _deviceIdManager = DeviceIdManager();
  final Dio _dio;
  bool _isRefreshing = false;
  final List<void Function(String)> _pendingRequests = [];

  AuthInterceptor(this._dbHelper, this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      String? token = AuthTokenManager().getToken();

      if (token != null &&
          token.isNotEmpty &&
          AuthTokenManager().shouldRefresh()) {
        final refreshToken = AuthTokenManager().getRefreshToken();

        if (refreshToken != null && refreshToken.isNotEmpty && !_isRefreshing) {
          _isRefreshing = true;

          try {
            log('Token about to expire, proactively refreshing',
                name: 'AuthInterceptor');

            final response = await _dio.post(
              '/auth/refresh',
              data: {'refresh_token': refreshToken},
            );

            if (response.statusCode == 200 && response.data != null) {
              final newTokenData = AuthTokenResponseDTO.fromJson(response.data);

              await _dbHelper.setData(
                collection: BDCollections.USERS,
                key: 'user',
                value: newTokenData.toJson(),
              );

              AuthTokenManager().setToken(
                newTokenData.accessToken,
                refreshToken: newTokenData.refreshToken,
                expiresIn: newTokenData.expiresIn,
              );

              token = newTokenData.accessToken;
              log('✅ Token proactively refreshed', name: 'AuthInterceptor');
            }
          } catch (e) {
            log('Error during proactive token refresh: $e',
                name: 'AuthInterceptor');
          } finally {
            _isRefreshing = false;
          }
        }
      }

      if (token == null || token.isEmpty) {
        final userData = await _dbHelper.getData(
          collection: BDCollections.USERS,
          key: 'user',
        );

        if (userData != null && userData is Map) {
          // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
          final userDataMap = <String, dynamic>{};
          userData.forEach((key, value) {
            if (key is String) {
              userDataMap[key] = value;
            } else {
              // Convert non-string keys to string
              userDataMap[key.toString()] = value;
            }
          });

          if (userDataMap.isNotEmpty) {
            try {
              final authData = AuthTokenResponseDTO.fromJson(userDataMap);
              final dbToken = authData.accessToken;

              if (dbToken.isNotEmpty) {
                AuthTokenManager().setToken(
                  dbToken,
                  refreshToken: authData.refreshToken,
                  expiresIn: authData.expiresIn,
                );
                token = dbToken;
                log('Token loaded from database for request: ${options.path}',
                    name: 'AuthInterceptor');
              }
            } catch (e) {
              log('⚠️ [AuthTokenManager] Error parsing token from database: $e',
                  name: 'AuthInterceptor');
            }
          }
        }
      }

      // Add token to request headers (only if token exists)
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        log('Added auth token to request: ${options.path}',
            name: 'AuthInterceptor');
      } else {
        // For anonymous users, add Device ID header
        try {
          final deviceId = await _deviceIdManager.getDeviceId();
          options.headers['X-Device-Id'] = deviceId;
          log('Added device ID for anonymous user: ${options.path}',
              name: 'AuthInterceptor');
        } catch (e) {
          log('Error getting device ID: $e', name: 'AuthInterceptor');
        }
      }
    } catch (e) {
      log('Error adding auth token: $e', name: 'AuthInterceptor');
      // Continue without token for anonymous access
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != '/auth/refresh') {
      log('Received 401 Unauthorized - attempting token refresh',
          name: 'AuthInterceptor');

      try {
        final userData = await _dbHelper.getData(
          collection: BDCollections.USERS,
          key: 'user',
        );

        if (userData != null && userData is Map) {
          final userDataMap = <String, dynamic>{};
          userData.forEach((key, value) {
            userDataMap[key is String ? key : key.toString()] = value;
          });

          if (userDataMap.isNotEmpty) {
            final authData = AuthTokenResponseDTO.fromJson(userDataMap);
            final refreshToken = authData.refreshToken;

            if (refreshToken.isNotEmpty && !_isRefreshing) {
              _isRefreshing = true;

              try {
                final response = await _dio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                if (response.statusCode == 200 && response.data != null) {
                  final newTokenData =
                      AuthTokenResponseDTO.fromJson(response.data);

                  await _dbHelper.setData(
                    collection: BDCollections.USERS,
                    key: 'user',
                    value: newTokenData.toJson(),
                  );

                  AuthTokenManager().setToken(
                    newTokenData.accessToken,
                    refreshToken: newTokenData.refreshToken,
                    expiresIn: newTokenData.expiresIn,
                  );

                  log('✅ Token refreshed successfully, retrying request',
                      name: 'AuthInterceptor');

                  for (final callback in _pendingRequests) {
                    callback(newTokenData.accessToken);
                  }
                  _pendingRequests.clear();

                  err.requestOptions.headers['Authorization'] =
                      'Bearer ${newTokenData.accessToken}';

                  final retryResponse = await _dio.fetch(err.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                log('❌ Token refresh failed: $refreshError',
                    name: 'AuthInterceptor');
              } finally {
                _isRefreshing = false;
              }
            }
          }
        }
      } catch (e) {
        log('Error during token refresh attempt: $e', name: 'AuthInterceptor');
      }

      log('Clearing expired token and user data', name: 'AuthInterceptor');
      AuthTokenManager().clearToken();

      try {
        final userData = await _dbHelper.getData(
          collection: BDCollections.USERS,
          key: 'user',
        );

        if (userData != null) {
          await _dbHelper.deleteData(
              collection: BDCollections.USERS, key: 'user');
        }
      } catch (e) {
        log('Error clearing user data: $e', name: 'AuthInterceptor');
      }
    }

    return handler.next(err);
  }
}
