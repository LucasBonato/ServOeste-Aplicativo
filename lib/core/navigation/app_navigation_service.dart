import 'package:flutter/material.dart';
import 'package:serv_oeste/core/navigation/navigation_service.dart';
import 'package:serv_oeste/core/routing/routes.dart';

class AppNavigationService implements NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  AppNavigationService(this.navigatorKey);

  @override
  void goToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (_) => false,
    );
  }

  @override
  void goToHome() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.home,
      (_) => false,
    );
  }
}
