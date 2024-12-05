import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
// import 'package:serv_oeste/src/screens/servico/create_cliente_and_servico.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';

import '../screens/cliente/create_cliente.dart';
import '../screens/servico/create_servico.dart';
import '../screens/tecnico/tecnico.dart';
import '../screens/tecnico/create_tecnico.dart';

class CustomRouter {
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

      // "/updateTecnico": (context) => const UpdateTecnico(),
      // "/updateCliente": (context) => const UpdateCliente(),
      // "/updateServico": (context) => const UpdateServico()
    };
  }

  static String getCurrentRoute(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    return modalRoute?.settings.name ?? "Unknown";
  }
}
