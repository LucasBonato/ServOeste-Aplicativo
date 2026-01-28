import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/%20core/di/app_dependencies.dart';
import 'package:serv_oeste/src/screens/auth/login.dart';
import 'package:serv_oeste/src/shared/routing/custom_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDependencies dependencies = AppDependencies(navigatorKey);

  runApp(
    MultiBlocProvider(
      providers: dependencies.buildBlocProviders(),
      child: MultiProvider(
        providers: dependencies.buildProviders(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const LoginScreen(),
      onGenerateRoute: (settings) => CustomRouter.onGenerateRoute(settings, context),
    );
  }
}
