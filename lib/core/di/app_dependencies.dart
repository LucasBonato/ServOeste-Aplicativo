import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:serv_oeste/core/services/flutter_secure_storage_service.dart';
import 'package:serv_oeste/core/services/secure_storage_service.dart';
import 'package:serv_oeste/features/auth/data/auth_repository_implementation.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/features/cliente/data/cliente_client.dart';
import 'package:serv_oeste/features/cliente/data/cliente_repository_implementation.dart';
import 'package:serv_oeste/features/cliente/domain/cliente_repository.dart';
import 'package:serv_oeste/features/auth/data/auth_client.dart';
import 'package:serv_oeste/features/tecnico/data/tecnico_repository_implementation.dart';
import 'package:serv_oeste/features/tecnico/domain/tecnico_repository.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/features/endereco/data/endereco_client.dart';
import 'package:serv_oeste/features/servico/data/servico_client.dart';
import 'package:serv_oeste/features/tecnico/data/tecnico_client.dart';
import 'package:serv_oeste/features/user/data/user_client.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/logic/filtro_servico/filtro_servico_provider.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/shared/routing/routes.dart';

class AppDependencies {
  final GlobalKey<NavigatorState> navigatorKey;

  late final DioService dioService;
  late final AuthRepository authRepository;
  late final ClienteRepository clienteRepository;
  late final TecnicoRepository tecnicoRepository;
  late final ServicoClient servicoClient;
  late final EnderecoClient enderecoClient;
  late final UserClient userClient;
  late final SecureStorageService secureStorageService;

  AppDependencies(
    this.navigatorKey
  ) {
    _init();
  }

  void _init() {
    secureStorageService = FlutterSecureStorageService(const FlutterSecureStorage());

    dioService = DioService(secureStorageService);
    authRepository = AuthRepositoryImplementation(AuthClient(dioService.dio));

    dioService.addAuthInterceptors(authRepository, () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.login,
        (_) => false,
      );
    });

    clienteRepository = ClienteRepositoryImplementation(ClienteClient(dioService.dio));
    tecnicoRepository = TecnicoRepositoryImplementation(TecnicoClient(dioService.dio));
    servicoClient = ServicoClient(dioService.dio);
    enderecoClient = EnderecoClient(dioService.dio);
    userClient = UserClient(dioService.dio);
  }

  List<BlocProvider> buildBlocProviders() {
    return [
      BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository, secureStorageService)),
      BlocProvider<ClienteBloc>(create: (_) => ClienteBloc(clienteRepository)),
      BlocProvider<TecnicoBloc>(create: (_) => TecnicoBloc(tecnicoRepository)),
      BlocProvider<ServicoBloc>(create: (_) => ServicoBloc(servicoClient)),
      BlocProvider<EnderecoBloc>(create: (_) => EnderecoBloc(enderecoClient)),
      BlocProvider<UserBloc>(create: (_) => UserBloc(userClient)),
    ];
  }

  List<SingleChildWidget> buildProviders() {
    return [
      ChangeNotifierProvider(create: (_) => FiltroServicoProvider()),
      Provider<UserClient>.value(value: userClient),
      Provider<SecureStorageService>.value(value: secureStorageService),
    ];
  }
}
