class LoginRequestDTO {
  final String identifier;
  final String password;
  final String? deviceFcmToken;
  final String? deviceLanguage;

  const LoginRequestDTO({
    required this.identifier,
    required this.password,
    this.deviceFcmToken,
    this.deviceLanguage,
  });

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'password': password,
        if (deviceFcmToken != null) 'device_fcm_token': deviceFcmToken,
        if (deviceLanguage != null) 'device_language': deviceLanguage,
      };
}

class RegisterRequestDTO {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String? deviceFcmToken;
  final String? deviceLanguage;

  const RegisterRequestDTO({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.deviceFcmToken,
    this.deviceLanguage,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        if (deviceFcmToken != null) 'device_fcm_token': deviceFcmToken,
        if (deviceLanguage != null) 'device_language': deviceLanguage,
      };
}

class EmailFallbackResponseDTO {
  final bool success;
  final String message;
  final String? email;
  final String? id;

  const EmailFallbackResponseDTO({
    required this.success,
    required this.message,
    this.email,
    this.id,
  });

  factory EmailFallbackResponseDTO.fromJson(Map<String, dynamic> json) {
    return EmailFallbackResponseDTO(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      email: json['data']?['email'] as String?,
      id: json['data']?['id'] as String? ?? json['id'] as String?,
    );
  }

  bool get isSentViaEmail =>
      success &&
      (message.toLowerCase().contains('sent via email') ||
          message.toLowerCase().contains('enviado via email') ||
          message.toLowerCase().contains('enviado para o email'));
}

class AuthTokenResponseDTO {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final AuthUserSummaryDTO user;

  const AuthTokenResponseDTO({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthTokenResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponseDTO(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      user: AuthUserSummaryDTO.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}

class AuthUserSummaryDTO {
  final String id;
  final String name;
  final String email;
  final String activeRole;
  final List<String> roles;

  const AuthUserSummaryDTO({
    required this.id,
    required this.name,
    required this.email,
    required this.activeRole,
    required this.roles,
  });

  factory AuthUserSummaryDTO.fromJson(Map<String, dynamic> json) {
    return AuthUserSummaryDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      activeRole: json['active_role'] ?? '',
      roles: List<String>.from(json['role_name'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'active_role': activeRole,
      'role_name': roles,
    };
  }
}

class ForgotPasswordRequestDTO {
  final String identifier;

  const ForgotPasswordRequestDTO({required this.identifier});

  Map<String, dynamic> toJson() => {'identifier': identifier};
}

class VerifyCodeRequestDTO {
  final String identifier;
  final String code;

  const VerifyCodeRequestDTO({
    required this.identifier,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'code': code,
      };
}

class ResetPasswordRequestDTO {
  final String identifier;
  final String password;

  const ResetPasswordRequestDTO({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'password': password,
      };
}

class ResendCodeRequestDTO {
  final String identifier;

  const ResendCodeRequestDTO({required this.identifier});

  Map<String, dynamic> toJson() => {'identifier': identifier};
}
