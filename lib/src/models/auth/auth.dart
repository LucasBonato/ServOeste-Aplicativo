class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserInfo? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 3600,
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }
}

class UserInfo {
  final int id;
  final String username;
  final String role;

  UserInfo({
    required this.id,
    required this.username,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
