import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/clients/cliente_client.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/src/clients/servico_client.dart';
import 'package:serv_oeste/src/clients/tecnico_client.dart';
import 'package:serv_oeste/src/layouts/base_layout.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/filtro_servico/filtro_servico_provider.dart';
import 'package:serv_oeste/src/shared/routing/custom_router.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/screens/auth/login.dart';

void main() {
  final dioService = DioService();
  final authClient = AuthClient(dioService.dio, dioService.cookieJar);
  final tecnicoClient = TecnicoClient(dioService.dio);
  final clienteClient = ClienteClient(dioService.dio);
  final servicoClient = ServicoClient(dioService.dio);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authClient)),
        BlocProvider<TecnicoBloc>(create: (_) => TecnicoBloc(tecnicoClient)),
        BlocProvider<ClienteBloc>(create: (_) => ClienteBloc(clienteClient)),
        BlocProvider<ServicoBloc>(create: (_) => ServicoBloc(servicoClient)),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FiltroServicoProvider()),
        ],
        child: MyApp(
          navigatorKey: navigatorKey,
          dioService: dioService,
          authClient: authClient,
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final DioService dioService;
  final AuthClient authClient;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.dioService,
    required this.authClient,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    widget.dioService.addRefreshInterceptor(
      widget.authClient,
      onTokenRefreshFailed: _redirectToLogin,
    );
  }

  void _redirectToLogin() {
    widget.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serv-Oeste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      navigatorKey: widget.navigatorKey,
      home: const LoginScreen(),
      onGenerateRoute: (settings) =>
          CustomRouter.onGenerateRoute(settings, context),
    );
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
        widget.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BaseLayout()),
          (route) => false,
        );
      } else if (state is AuthLogoutSuccessState ||
          state is UnauthenticatedState) {
        widget.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }
}
