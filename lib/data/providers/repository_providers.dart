import 'dart:developer';

/// Classe para armazenar token de autenticação globalmente
/// Usado pelos repositórios para fazer requests autenticados
class AuthTokenManager {
  static final AuthTokenManager _instance = AuthTokenManager._internal();
  factory AuthTokenManager() => _instance;
  AuthTokenManager._internal();

  String? _token;

  String? get token {
    if (_token != null) {
      log('🔑 [AuthTokenManager] Token retrieved (${_token!.length} chars, first 20: ${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...)', 
          name: 'AuthTokenManager');
    } else {
      log('⚠️ [AuthTokenManager] Token is NULL', name: 'AuthTokenManager');
    }
    return _token;
  }

  void setToken(String? token) {
    _token = token;
    if (token != null) {
      log('✅ [AuthTokenManager] Token set successfully (${token.length} chars)', 
          name: 'AuthTokenManager');
      log('🔑 [AuthTokenManager] Token format: Bearer $token', 
          name: 'AuthTokenManager');
    } else {
      log('⚠️ [AuthTokenManager] Token set to NULL', name: 'AuthTokenManager');
    }
  }

  void clearToken() {
    _token = null;
    log('🗑️ [AuthTokenManager] Token cleared', name: 'AuthTokenManager');
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;
}
