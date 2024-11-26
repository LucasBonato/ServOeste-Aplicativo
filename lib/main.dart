import 'package:flutter/material.dart';
import 'package:serv_oeste/src/screens/home.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico.dart';
import 'package:serv_oeste/src/layouts/base_layout.dart';
import 'package:serv_oeste/src/shared/custom_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServOeste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: BaseLayout(
        initialIndex: 0,
        screens: const [
          Home(),
          TecnicoPage(),
          ClientePage(),
          Servico(),
        ],
      ),
      routes: CustomRouter.getRoutes(context),
    );
  }
}
