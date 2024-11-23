import 'package:flutter/material.dart';

import '../screens/cliente/cliente.dart';
import '../screens/cliente/create_cliente.dart';
import '../screens/servico/servico.dart';
import '../screens/servico/create_servico.dart';
import '../screens/tecnico/tecnico.dart';
import '../screens/tecnico/create_tecnico.dart';

class CustomRouter {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      "/tecnico": (context) => const TecnicoPage(),
      "/createTecnico": (context) => const CreateTecnico(),
      "/cliente": (context) => const ClientePage(),
      "/createCliente": (context) => const CreateCliente(),
      "/servico": (context) => const Servico(),
      "/createServico": (context) => const CreateServico()
    };
  }

  static String getCurrentRoute(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    return modalRoute?.settings.name ?? "Unknown";
  }
}
