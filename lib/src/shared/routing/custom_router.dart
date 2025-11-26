import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';
import 'package:serv_oeste/src/screens/servico/update_servico.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import 'package:serv_oeste/src/screens/user/create_user.dart';
import 'package:serv_oeste/src/screens/user/user.dart';
import 'package:serv_oeste/src/shared/routing/routes.dart';

import '../../screens/cliente/create_cliente.dart';
import '../../screens/servico/create_servico.dart';
import '../../screens/servico/filter_servico.dart';
import '../../screens/servico/servico.dart';
import '../../screens/tecnico/create_tecnico.dart';
import '../../screens/tecnico/tecnico.dart';

class CustomRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings, BuildContext context) {
    final TecnicoBloc tecnicoBloc = context.read<TecnicoBloc>();
    final ClienteBloc clienteBloc = context.read<ClienteBloc>();
    final UserBloc userBloc = context.read<UserBloc>();
    final ServicoBloc servicoBloc = context.read<ServicoBloc>();

    final routes = <String, Widget Function(BuildContext)>{
      Routes.tecnico: (_) => const TecnicoScreen(),
      Routes.tecnicoCreate: (_) => const CreateTecnico(),
      Routes.cliente: (_) => const ClienteScreen(),
      Routes.clienteCreate: (_) => const CreateCliente(),
      Routes.servico: (_) => const ServicoScreen(),
      Routes.servicoFilter: (_) => const FilterService(),
      Routes.user: (_) => const UserScreen(),
      Routes.userCreate: (_) => const CreateUserScreen(),
    };

    if (routes.containsKey(settings.name)) {
      return createRoute(routes[settings.name]!, _getBloc(settings.name!, tecnicoBloc, clienteBloc, userBloc, servicoBloc));
    }

    switch (settings.name) {
      case Routes.tecnicoUpdate:
        return createRoute((_) => UpdateTecnico(id: settings.arguments as int), tecnicoBloc);
      case Routes.clienteUpdate:
        return createRoute((_) => UpdateCliente(id: settings.arguments as int), clienteBloc);
      case Routes.servicoUpdate:
        return createRoute((_) => UpdateServico(id: settings.arguments as int, clientId: settings.arguments as int), servicoBloc);
      case Routes.servicoCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        return createRoute((_) => CreateServico(isClientAndService: args?['isClientAndService'] ?? true), servicoBloc);
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
