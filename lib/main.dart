import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/src/layouts/base_layout.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/filter_service/filter_service_provider.dart';
import 'package:serv_oeste/src/shared/custom_router.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TecnicoBloc>(create: (_) => TecnicoBloc()),
        BlocProvider<ClienteBloc>(create: (_) => ClienteBloc()),
        BlocProvider<ServicoBloc>(create: (_) => ServicoBloc()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FilterServiceProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServOeste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const BaseLayout(),
      routes: CustomRouter.getRoutes(context),
    );
  }
}
