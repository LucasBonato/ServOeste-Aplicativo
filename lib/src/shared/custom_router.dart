import 'package:flutter/material.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';

import '../screens/cliente/create_cliente.dart';
import '../screens/servico/create_servico.dart';
import '../screens/tecnico/tecnico.dart';
import '../screens/tecnico/create_tecnico.dart';

class CustomRouter {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      "/tecnico": (context) => const TecnicoScreen(),
      "/createTecnico": (context) => const CreateTecnico(),
      // "/updateTecnico": (context) => const UpdateTecnico(),
      "/cliente": (context) => const ClienteScreen(),
      "/createCliente": (context) => const CreateCliente(),
      // "/updateCliente": (context) => const UpdateCliente(),
      "/servico": (context) => ServicesScreen(),
      "/filterServico": (context) => FilterService(),
      "/createServico": (context) => const CreateServico(),
      // "/updateServico": (context) => const UpdateServico()
    };
  }

  static String getCurrentRoute(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    return modalRoute?.settings.name ?? "Unknown";
  }
}
