import 'package:flutter/material.dart';
import 'package:serv_oeste/pages/cliente/cliente.dart';
import 'package:serv_oeste/pages/cliente/create_cliente.dart';
import 'package:serv_oeste/pages/cliente/update_cliente.dart';
import 'package:serv_oeste/pages/tecnico/create_tecnico.dart';
import 'package:serv_oeste/pages/home_page.dart';
import 'package:serv_oeste/pages/tecnico/tecnico.dart';
import 'package:serv_oeste/pages/tecnico/update_tecnico.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int indexAtual = 1;
  Widget paginaAtual = const HomePage();

  void changePage(int index, {int? id}){
    indexAtual = (index > 2) ? indexAtual : index;
    switch(index){
      case 0:
        setState(() {
          paginaAtual = ClientePage(
              onFabPressed: () {changePage(12);},
              onEditPressed: (idUpdate) {changePage(13, id: idUpdate);}
          );
        });
        break;
      case 1:
        setState(() {
          paginaAtual = const HomePage();
        });
        break;
      case 2:
        setState(() {
          paginaAtual = TecnicoPage(
              onFabPressed: () {changePage(22);},
              onEditPressed: (idUpdate) {changePage(23, id: idUpdate);}
          );
        });
        break;
      case 12:
        setState(() {
          paginaAtual = CreateCliente(onIconPressed: () {changePage(0);});
        });
        break;
      case 13:
        setState(() {
          paginaAtual = UpdateCliente(onIconPressed: () {changePage(0);}, id: id!);
        });
        break;
      case 22:
        setState(() {
          paginaAtual = CreateTecnico(onIconPressed: () {changePage(2);});
        });
        break;
      case 23:
        setState(() {
          paginaAtual = UpdateTecnico(onIconPressed: () {changePage(2);}, id: id!);
        });
        break;
    }
  }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
      appBar: AppBar(
        title: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'images/servOeste.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0),
          ),
        ),
        centerTitle: true,
      ),
			body: paginaAtual,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: "Cliente",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.attribution),
              label: "Técnico"
          ),
        ],
        currentIndex: indexAtual,
        onTap: (index) => changePage(index),
      ),
		);
	}
}
