import 'package:flutter/material.dart';

class UserForm extends ChangeNotifier {
  int? id;
  ValueNotifier<String> username = ValueNotifier("");
  ValueNotifier<String> password = ValueNotifier("");
  ValueNotifier<String> role = ValueNotifier("EMPLOYEE");

  void setId(int id) {
    this.id = id;
    notifyListeners();
  }

  void setUsername(String value) {
    username.value = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password.value = value;
    notifyListeners();
  }

  void setRole(String value) {
    role.value = value;
    notifyListeners();
  }

  bool get isValid {
    return username.value.isNotEmpty &&
        password.value.isNotEmpty &&
        role.value.isNotEmpty;
  }

  bool get isValidForUpdate {
    return id != null && isValid;
  }

  Map<String, dynamic> toRegisterRequest() {
    return {
      'username': username.value,
      'password': password.value,
      'role': role.value,
    };
  }

  Map<String, dynamic> toUpdateRequest() {
    return {
      'id': id,
      'username': username.value,
      'password': password.value,
      'role': role.value,
    };
  }

  void clear() {
    id = null;
    username.value = "";
    password.value = "";
    role.value = "EMPLOYEE";
    notifyListeners();
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    role.dispose();
    super.dispose();
  }
}
