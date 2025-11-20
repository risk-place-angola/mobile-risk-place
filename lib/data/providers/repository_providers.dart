import 'dart:developer';

class AuthTokenManager {
  static final AuthTokenManager _instance = AuthTokenManager._internal();
  factory AuthTokenManager() => _instance;
  AuthTokenManager._internal();

  String? _token;
  String? _refreshToken;
  int? _expiresAt;

  String? get token {
    if (_token != null) {
      log('🔑 [AuthTokenManager] Token retrieved (${_token!.length} chars, first 20: ${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...)',
          name: 'AuthTokenManager');
    } else {
      log('⚠️ [AuthTokenManager] Token is NULL', name: 'AuthTokenManager');
    }
    return _token;
  }

  void setToken(String? token, {String? refreshToken, int? expiresIn}) {
    _token = token;
    _refreshToken = refreshToken;

    if (expiresIn != null) {
      _expiresAt = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    }

    if (token != null) {
      log('✅ [AuthTokenManager] Token set successfully (${token.length} chars)',
          name: 'AuthTokenManager');
      log('🔑 [AuthTokenManager] Token format: Bearer $token',
          name: 'AuthTokenManager');
    } else {
      log('⚠️ [AuthTokenManager] Token set to NULL', name: 'AuthTokenManager');
    }
  }

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
    log('🗑️ [AuthTokenManager] Token cleared', name: 'AuthTokenManager');
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;
}
