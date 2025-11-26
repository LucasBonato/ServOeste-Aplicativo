import 'package:serv_oeste/src/models/user/user_form.dart';

class User {
  int? id;
  String? username;
  String? role;

  User({
    required this.id,
    required this.username,
    required this.role,
  });

  User.fromForm(UserForm userForm) {
    id = userForm.id;
    username = userForm.username.value;
    role = userForm.role.value;
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
      };
}
