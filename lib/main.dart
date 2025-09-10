import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/src/layouts/base_layout.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/filtro_servico/filtro_servico_provider.dart';
import 'package:serv_oeste/src/shared/routing/custom_router.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/screens/auth/login.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<TecnicoBloc>(create: (_) => TecnicoBloc()),
        BlocProvider<ClienteBloc>(create: (_) => ClienteBloc()),
        BlocProvider<ServicoBloc>(create: (_) => ServicoBloc()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FiltroServicoProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serv-Oeste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      navigatorKey: _navigatorKey,
      home: const LoginScreen(),
      onGenerateRoute: (settings) =>
          CustomRouter.onGenerateRoute(settings, context),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthCheckStatusEvent());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    final authBloc = context.read<AuthBloc>();
    authBloc.stream.listen((state) {
      if (state is AuthenticatedState || state is AuthLoginSuccessState) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BaseLayout()),
          (route) => false,
        );
      } else if (state is AuthLogoutSuccessState ||
          state is UnauthenticatedState) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }
}
