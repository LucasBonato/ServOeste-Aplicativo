import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';
import 'package:serv_oeste/src/screens/servico/update_servico2.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import '../screens/cliente/create_cliente.dart';
import '../screens/servico/create_servico.dart';
import '../screens/tecnico/tecnico.dart';
import '../screens/tecnico/create_tecnico.dart';
import '../screens/servico/servico.dart';
import '../screens/servico/filter_servico.dart';

class CustomRouter {
  static Route<dynamic>? onGenerateRoute(
      RouteSettings settings, BuildContext context) {
    final TecnicoBloc tecnicoBloc = context.read<TecnicoBloc>();
    final ClienteBloc clienteBloc = context.read<ClienteBloc>();
    final ServicoBloc servicoBloc = context.read<ServicoBloc>();

    switch (settings.name) {
      case "/tecnico":
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: tecnicoBloc,
            child: const TecnicoScreen(),
          ),
        );

      case "/createTecnico":
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: tecnicoBloc,
            child: const CreateTecnico(),
          ),
        );

      case "/updateTecnico":
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: tecnicoBloc,
            child: UpdateTecnico(id: id),
          ),
        );

      case "/cliente":
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: clienteBloc,
            child: const ClienteScreen(),
          ),
        );

      case "/createCliente":
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: clienteBloc,
            child: const CreateCliente(),
          ),
        );

      case "/updateCliente":
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: clienteBloc,
            child: UpdateCliente(id: id),
          ),
        );

      case "/servico":
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: servicoBloc,
            child: const ServicoScreen(),
          ),
        );

      case "/filterServico":
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: servicoBloc,
            child: FilterService(),
          ),
        );

      case "/createServico":
        final args = settings.arguments as Map<String, dynamic>?;
        final isClientAndService = args?['isClientAndService'] ?? true;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: servicoBloc,
            child: CreateServico(isClientAndService: isClientAndService),
          ),
        );

      case "/updateServico":
        final id = settings.arguments as int;
        print(id);
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: servicoBloc,
            child: UpdateServico(id: id),
          ),
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

  static String getCurrentRoute(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    return modalRoute?.settings.name ?? "Unknown";
  }
}
