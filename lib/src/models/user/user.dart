import 'package:serv_oeste/src/models/user/user_form.dart';

class User {
  final int id;
  final String username;
  final String role;
  final String? passwordHash;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.passwordHash,
  });

  User.fromForm(UserForm userForm)
      : id = userForm.id!,
        username = userForm.username.value,
        role = userForm.role.value,
        passwordHash = userForm.password.value;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        role: json['role'] as String,
        passwordHash: json['passwordHash'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        if (passwordHash != null) 'passwordHash': passwordHash,
      };
}
