class LoginRequestDTO {
  final String email;
  final String password;

  const LoginRequestDTO({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequestDTO {
  final String name;
  final String email;
  final String password;
  final String phone;

  const RegisterRequestDTO({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      };
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
