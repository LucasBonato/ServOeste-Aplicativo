import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import '../screens/cliente/create_cliente.dart';
import '../screens/servico/create_servico.dart';
import '../screens/tecnico/tecnico.dart';
import '../screens/tecnico/create_tecnico.dart';
import '../screens/servico/servico.dart';
import '../screens/servico/filter_servico.dart';

class CustomRouter {
  /// Define as rotas que necessitam argumentos usando onGenerateRoute.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/updateTecnico":
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) {
            final tecnicoBloc = context.read<TecnicoBloc>();
            return BlocProvider.value(
              value: tecnicoBloc,
              child: UpdateTecnico(id: id),
            );
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("Rota desconhecida: ${settings.name}"),
            ),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    final TecnicoBloc tecnicoBloc = context.read<TecnicoBloc>();
    final ClienteBloc clienteBloc = context.read<ClienteBloc>();
    final ServicoBloc servicoBloc = context.read<ServicoBloc>();

    return {
      "/tecnico": (context) => BlocProvider.value(
            value: tecnicoBloc,
            child: const TecnicoScreen(),
          ),
      "/createTecnico": (context) => BlocProvider.value(
            value: tecnicoBloc,
            child: const CreateTecnico(),
          ),
      "/cliente": (context) => BlocProvider.value(
            value: clienteBloc,
            child: const ClienteScreen(),
          ),
      "/createCliente": (context) => BlocProvider.value(
            value: clienteBloc,
            child: const CreateCliente(),
          ),
      "/servico": (context) => BlocProvider.value(
            value: servicoBloc,
            child: const ServicoScreen(),
          ),
      "/filterServico": (context) => BlocProvider.value(
            value: servicoBloc,
            child: FilterService(),
          ),
      "/createServico": (context) => BlocProvider.value(
            value: servicoBloc,
            child: CreateServicoAndCliente(),
          ),
    };
  }

  static String getCurrentRoute(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    return modalRoute?.settings.name ?? "Unknown";
  }
}
