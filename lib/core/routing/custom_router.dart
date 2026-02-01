import 'package:flutter/material.dart';
import 'package:serv_oeste/core/routing/args/cliente_update_args.dart';
import 'package:serv_oeste/core/routing/args/servico_create_args.dart';
import 'package:serv_oeste/core/routing/args/servico_filter_form_args.dart';
import 'package:serv_oeste/core/routing/args/servico_update_args.dart';
import 'package:serv_oeste/core/routing/args/tecnico_update_args.dart';
import 'package:serv_oeste/core/routing/args/user_update_args.dart';
import 'package:serv_oeste/core/routing/routes.dart';
import 'package:serv_oeste/features/auth/presentation/screens/login.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_create_screen.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_screen.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_update_screen.dart';
import 'package:serv_oeste/features/servico/presentation/screens/servico_create_screen.dart';
import 'package:serv_oeste/features/servico/presentation/screens/servico_screen.dart';
import 'package:serv_oeste/features/servico/presentation/screens/servico_update_screen.dart';
import 'package:serv_oeste/features/servico/presentation/widgets/servico_filter_form_widget.dart';
import 'package:serv_oeste/features/tecnico/presentation/screens/tecnico_create_screen.dart';
import 'package:serv_oeste/features/tecnico/presentation/screens/tecnico_screen.dart';
import 'package:serv_oeste/features/tecnico/presentation/screens/tecnico_update_screen.dart';
import 'package:serv_oeste/features/user/presentation/screens/user_create_screen.dart';
import 'package:serv_oeste/features/user/presentation/screens/user_screen.dart';
import 'package:serv_oeste/features/user/presentation/screens/user_update_screen.dart';
import 'package:serv_oeste/shared/widgets/layout/base_layout.dart';

class CustomRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const BaseLayout());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.tecnico:
        return MaterialPageRoute(builder: (_) => const TecnicoScreen());
      case Routes.tecnicoCreate:
        return MaterialPageRoute(builder: (_) => const TecnicoCreateScreen());
      case Routes.tecnicoUpdate:
        final TecnicoUpdateArgs args = settings.arguments as TecnicoUpdateArgs;
        return MaterialPageRoute(builder: (_) => TecnicoUpdateScreen(id: args.id));
      case Routes.cliente:
        return MaterialPageRoute(builder: (_) => const ClienteScreen());
      case Routes.clienteCreate:
        return MaterialPageRoute(builder: (_) => const ClienteCreateScreen());
      case Routes.clienteUpdate:
        final ClienteUpdateArgs args = settings.arguments as ClienteUpdateArgs;
        return MaterialPageRoute(builder: (_) => ClienteUpdateScreen(id: args.id));
      case Routes.servico:
        return MaterialPageRoute(builder: (_) => const ServicoScreen());
      case Routes.servicoCreate:
        final ServicoCreateArgs args = settings.arguments as ServicoCreateArgs;
        return MaterialPageRoute(
          builder: (_) => ServicoCreateScreen(
            isClientAndService: args.isClientAndService,
          ),
        );
      case Routes.servicoUpdate:
        final ServicoUpdateArgs args = settings.arguments as ServicoUpdateArgs;
        return MaterialPageRoute(builder: (_) => ServicoUpdateScreen(id: args.id, clientId: args.clientId));
      case Routes.servicoFilter:
        final ServicoFilterFormArgs args = settings.arguments as ServicoFilterFormArgs;
        return MaterialPageRoute(builder: (_) => ServicoFilterFormWidget(bloc: args.bloc, title: args.title, submitText: args.submitText, form: args.form));
      case Routes.user:
        return MaterialPageRoute(builder: (_) => const UserScreen());
      case Routes.userCreate:
        return MaterialPageRoute(builder: (_) => const UserCreateScreen());
      case Routes.userUpdate:
        final UserUpdateArgs args = settings.arguments as UserUpdateArgs;
        return MaterialPageRoute(
          builder: (_) => UserUpdateScreen(
            id: args.id,
            username: args.username,
            role: args.role,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text("Rota desconhecida: ${settings.name}")),
          ),
        );
    }
  }
}
