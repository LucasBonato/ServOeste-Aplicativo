class UserRegisterRequest {
  final String username;
  final String password;
  final String role;

  UserRegisterRequest({
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
      };
}
