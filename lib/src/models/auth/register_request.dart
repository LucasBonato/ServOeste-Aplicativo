class RegisterRequest {
  final String username;
  final String password;
  final String role;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'role': role,
    };
  }
}
