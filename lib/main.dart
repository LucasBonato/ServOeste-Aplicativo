import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/core/di/app_dependencies.dart';
import 'package:serv_oeste/core/navigation/app_navigation_service.dart';
import 'package:serv_oeste/core/navigation/navigation_service.dart';
import 'package:serv_oeste/core/routing/custom_router.dart';
import 'package:serv_oeste/core/routing/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  final NavigationService navigationService = AppNavigationService(navigatorKey);
  final AppDependencies dependencies = AppDependencies(navigationService);

  runApp(
    MultiBlocProvider(
      providers: dependencies.buildBlocProviders(),
      child: MultiProvider(
        providers: dependencies.buildProviders(),
        child: MyApp(navigatorKey: navigatorKey),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serv-Oeste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: Routes.login,
      onGenerateRoute: (settings) => CustomRouter.onGenerateRoute(settings),
    );
  }
}
