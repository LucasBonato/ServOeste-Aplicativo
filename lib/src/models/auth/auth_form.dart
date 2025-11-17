import 'package:flutter/material.dart';

class AuthForm extends ChangeNotifier {
  ValueNotifier<String> username = ValueNotifier("");
  ValueNotifier<String> password = ValueNotifier("");

  void setUsername(String? username) {
    this.username.value = username ?? "";
    notifyListeners();
  }

  void setPassword(String? password) {
    this.password.value = password ?? "";
    notifyListeners();
  }

  void clear() {
    username.value = "";
    password.value = "";
    notifyListeners();
  }

  bool isLoginValid() {
    return username.value.isNotEmpty && password.value.isNotEmpty;
  }
}
