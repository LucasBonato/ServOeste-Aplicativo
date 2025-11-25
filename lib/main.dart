import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/clients/cliente_client.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/src/clients/endereco_client.dart';
import 'package:serv_oeste/src/clients/servico_client.dart';
import 'package:serv_oeste/src/clients/tecnico_client.dart';
import 'package:serv_oeste/src/clients/user_client.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/logic/filtro_servico/filtro_servico_provider.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/screens/auth/login.dart';
import 'package:serv_oeste/src/shared/routing/custom_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DioService dioService = DioService();
  final authClient = AuthClient(dioService.dio);

  dioService.addAuthInterceptors(
      authClient,
      () {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false
        );
      }
  );

  final tecnicoClient = TecnicoClient(dioService.dio);
  final clienteClient = ClienteClient(dioService.dio);
  final servicoClient = ServicoClient(dioService.dio);
  final enderecoClient = EnderecoClient(dioService.dio);
  final userClient = UserClient(dioService.dio);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authClient)),
        BlocProvider<TecnicoBloc>(create: (_) => TecnicoBloc(tecnicoClient)),
        BlocProvider<ClienteBloc>(create: (_) => ClienteBloc(clienteClient)),
        BlocProvider<ServicoBloc>(create: (_) => ServicoBloc(servicoClient)),
        BlocProvider<EnderecoBloc>(create: (_) => EnderecoBloc(enderecoClient)),
        BlocProvider<UserBloc>(create: (_) => UserBloc(userClient)),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FiltroServicoProvider()),
          Provider<UserClient>(create: (_) => userClient),
        ],
        child: MyApp(
          dioService: dioService,
          authClient: authClient,
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final DioService dioService;
  final AuthClient authClient;

  const MyApp({
    super.key,
    required this.dioService,
    required this.authClient,
  });

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
