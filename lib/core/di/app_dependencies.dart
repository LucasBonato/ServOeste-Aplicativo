import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
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

class AppDependencies {
  final GlobalKey<NavigatorState> navigatorKey;

  late final DioService dioService;
  late final AuthClient authClient;
  late final ClienteClient clienteClient;
  late final TecnicoClient tecnicoClient;
  late final ServicoClient servicoClient;
  late final EnderecoClient enderecoClient;
  late final UserClient userClient;

  AppDependencies(
    this.navigatorKey
  ) {
    _init();
  }

  void _init() {
    dioService = DioService();
    authClient = AuthClient(dioService.dio);

    dioService.addAuthInterceptors(authClient, () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    });

    clienteClient = ClienteClient(dioService.dio);
    tecnicoClient = TecnicoClient(dioService.dio);
    servicoClient = ServicoClient(dioService.dio);
    enderecoClient = EnderecoClient(dioService.dio);
    userClient = UserClient(dioService.dio);
  }

  List<BlocProvider> buildBlocProviders() {
    return [
      BlocProvider<AuthBloc>(create: (_) => AuthBloc(authClient)),
      BlocProvider<ClienteBloc>(create: (_) => ClienteBloc(clienteClient)),
      BlocProvider<TecnicoBloc>(create: (_) => TecnicoBloc(tecnicoClient)),
      BlocProvider<ServicoBloc>(create: (_) => ServicoBloc(servicoClient)),
      BlocProvider<EnderecoBloc>(create: (_) => EnderecoBloc(enderecoClient)),
      BlocProvider<UserBloc>(create: (_) => UserBloc(userClient)),
    ];
  }

  List<SingleChildWidget> buildProviders() {
    return [
      ChangeNotifierProvider(create: (_) => FiltroServicoProvider()),
      Provider<UserClient>.value(value: userClient),
    ];
  }
}
