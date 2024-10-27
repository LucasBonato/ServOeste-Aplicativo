import 'package:flutter/material.dart';

import 'package:serv_oeste/src/screens/home.dart';
import '../screens/cliente/create_cliente.dart';
import '../screens/servico/create_servico.dart';
import '../screens/tecnico/create_tecnico.dart';

class CustomRouter {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      "/": (context) => const Home(),
      "/createTecnico": (context) => const CreateTecnico(),
      "/createCliente": (context) => const CreateCliente(),
      "/createServico": (context) => const CreateServico()
    };
  }

  static String getCurrentRoute(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    return modalRoute?.settings.name ?? "Unknown";
  }
}