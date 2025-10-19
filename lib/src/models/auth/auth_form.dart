import 'package:flutter/material.dart';

class AuthForm extends ChangeNotifier {
  ValueNotifier<String> username = ValueNotifier("");
  ValueNotifier<String> password = ValueNotifier("");
  ValueNotifier<String> role = ValueNotifier("");

  void setUsername(String? username) {
    this.username.value = username ?? "";
    notifyListeners();
  }

  void setPassword(String? password) {
    this.password.value = password ?? "";
    notifyListeners();
  }

  void setRole(String? role) {
    this.role.value = role ?? "";
    notifyListeners();
  }

  void clear() {
    username.value = "";
    password.value = "";
    role.value = "";
    notifyListeners();
  }

  bool isLoginValid() {
    return username.value.isNotEmpty && password.value.isNotEmpty;
  }

  bool isRegisterValid() {
    return username.value.isNotEmpty && password.value.isNotEmpty && role.value.isNotEmpty;
  }
}
