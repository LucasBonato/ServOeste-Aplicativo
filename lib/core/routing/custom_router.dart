import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/core/routing/routes.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_create_screen.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_update_screen.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/features/servico/presentation/screens/servico_create_screen.dart';
import 'package:serv_oeste/features/servico/presentation/screens/servico_screen.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/tecnico/presentation/screens/tecnico_create_screen.dart';
import 'package:serv_oeste/features/tecnico/presentation/screens/tecnico_screen.dart';
import 'package:serv_oeste/features/tecnico/presentation/screens/tecnico_update_screen.dart';
import 'package:serv_oeste/features/user/presentation/bloc/user_bloc.dart';
import 'package:serv_oeste/features/auth/presentation/screens/login.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_screen.dart';
import 'package:serv_oeste/features/servico/presentation/screens/servico_update_screen.dart';
import 'package:serv_oeste/features/user/presentation/screens/user_create_screen.dart';
import 'package:serv_oeste/features/user/presentation/screens/user_screen.dart';

class CustomRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings, BuildContext context) {
    final TecnicoBloc tecnicoBloc = context.read<TecnicoBloc>();
    final ClienteBloc clienteBloc = context.read<ClienteBloc>();
    final ServicoBloc servicoBloc = context.read<ServicoBloc>();
    final UserBloc userBloc = context.read<UserBloc>();

    final routes = <String, Widget Function(BuildContext)>{
      Routes.login: (_) => const LoginScreen(),
      Routes.tecnico: (_) => const TecnicoScreen(),
      Routes.tecnicoCreate: (_) => const TecnicoCreateScreen(),
      Routes.cliente: (_) => const ClienteScreen(),
      Routes.clienteCreate: (_) => const ClienteCreateScreen(),
      Routes.servico: (_) => const ServicoScreen(),
      Routes.user: (_) => const UserScreen(),
      Routes.userCreate: (_) => const CreateUserScreen(),
    };

    if (routes.containsKey(settings.name)) {
      return createRoute(routes[settings.name]!, _getBloc(settings.name!, tecnicoBloc, clienteBloc, userBloc, servicoBloc));
    }

    switch (settings.name) {
      case Routes.tecnicoUpdate:
        return createRoute((_) => TecnicoUpdateScreen(id: settings.arguments as int), tecnicoBloc);
      case Routes.clienteUpdate:
        return createRoute((_) => ClienteUpdateScreen(id: settings.arguments as int), clienteBloc);
      case Routes.servicoUpdate:
        return createRoute((_) => ServicoUpdateScreen(id: settings.arguments as int, clientId: settings.arguments as int), servicoBloc);
      case Routes.servicoCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        return createRoute((_) => ServicoCreateScreen(isClientAndService: args?['isClientAndService'] ?? true), servicoBloc);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text("Rota desconhecida: ${settings.name}")),
          ),
        );
    }
  }

  static Route<dynamic> createRoute<T extends StateStreamableSource<Object?>>(Widget Function(BuildContext) builder, T bloc) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<T>.value(value: bloc, child: builder(context)),
    );
  }

  static StateStreamableSource<Object?> _getBloc(String route, TecnicoBloc tecnicoBloc, ClienteBloc clienteBloc, UserBloc userBloc, ServicoBloc servicoBloc) {
    if (route.contains("tecnico")) return tecnicoBloc;
    if (route.contains("cliente")) return clienteBloc;
    if (route.contains("user")) return userBloc;
    return servicoBloc;
  }

  static String getCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ?? "Unknown";
  }
}
