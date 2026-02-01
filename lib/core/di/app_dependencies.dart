import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:serv_oeste/core/http/dio_service.dart';
import 'package:serv_oeste/core/navigation/navigation_service.dart';
import 'package:serv_oeste/core/services/flutter_secure_storage_service.dart';
import 'package:serv_oeste/core/services/secure_storage_service.dart';
import 'package:serv_oeste/features/auth/data/auth_client.dart';
import 'package:serv_oeste/features/auth/data/auth_repository_implementation.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:serv_oeste/features/cliente/data/cliente_client.dart';
import 'package:serv_oeste/features/cliente/data/cliente_repository_implementation.dart';
import 'package:serv_oeste/features/cliente/domain/cliente_repository.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/endereco/data/endereco_client.dart';
import 'package:serv_oeste/features/endereco/data/endereco_repository_implementation.dart';
import 'package:serv_oeste/features/endereco/domain/endereco_repository.dart';
import 'package:serv_oeste/features/endereco/presentation/bloc/endereco_bloc.dart';
import 'package:serv_oeste/features/servico/data/servico_client.dart';
import 'package:serv_oeste/features/servico/data/servico_repository_implementation.dart';
import 'package:serv_oeste/features/servico/domain/servico_repository.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/features/tecnico/data/tecnico_client.dart';
import 'package:serv_oeste/features/tecnico/data/tecnico_repository_implementation.dart';
import 'package:serv_oeste/features/tecnico/domain/tecnico_repository.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/user/data/user_client.dart';
import 'package:serv_oeste/features/user/data/user_repository_implementation.dart';
import 'package:serv_oeste/features/user/domain/user_repository.dart';
import 'package:serv_oeste/features/user/presentation/bloc/user_bloc.dart';

class AppDependencies {
  final NavigationService navigationService;

  late final DioService dioService;
  late final AuthRepository authRepository;
  late final ClienteRepository clienteRepository;
  late final TecnicoRepository tecnicoRepository;
  late final ServicoRepository servicoRepository;
  late final EnderecoRepository enderecoRepository;
  late final UserRepository userRepository;
  late final SecureStorageService secureStorageService;

  AppDependencies(
    this.navigationService
  ) {
    _init();
  }

  void _init() {
    secureStorageService = FlutterSecureStorageService(const FlutterSecureStorage());

    dioService = DioService(secureStorageService);
    authRepository = AuthRepositoryImplementation(AuthClient(dioService.dio));

    dioService.addAuthInterceptors(authRepository, () {
      navigationService.goToLogin();
    });

    clienteRepository = ClienteRepositoryImplementation(ClienteClient(dioService.dio));
    tecnicoRepository = TecnicoRepositoryImplementation(TecnicoClient(dioService.dio));
    servicoRepository = ServicoRepositoryImplementation(ServicoClient(dioService.dio));
    enderecoRepository = EnderecoRepositoryImplementation(EnderecoClient(dioService.dio));
    userRepository = UserRepositoryImplementation(UserClient(dioService.dio));
  }

  List<BlocProvider> buildBlocProviders() {
    return [
      BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository, secureStorageService)),
      BlocProvider<ClienteBloc>(create: (_) => ClienteBloc(clienteRepository)),
      BlocProvider<TecnicoBloc>(create: (_) => TecnicoBloc(tecnicoRepository)),
      BlocProvider<ServicoBloc>(create: (_) => ServicoBloc(servicoRepository)),
      BlocProvider<EnderecoBloc>(create: (_) => EnderecoBloc(enderecoRepository)),
      BlocProvider<UserBloc>(create: (_) => UserBloc(userRepository)),
    ];
  }

  List<SingleChildWidget> buildProviders() {
    return [
      Provider<SecureStorageService>.value(value: secureStorageService),
      Provider<NavigationService>.value(value: navigationService),
    ];
  }
}
