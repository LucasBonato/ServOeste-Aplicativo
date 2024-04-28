import 'package:flutter/material.dart';
import 'package:serv_oeste/pages/create_tecnico_page.dart';
import 'package:serv_oeste/pages/home_page.dart';
import 'package:serv_oeste/pages/tecnico_page.dart';
import 'package:serv_oeste/pages/update_tecnico_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int indexAtual = 0;
  Widget paginaAtual = const HomePage();

  void changePage(int index, {int? id}){
    indexAtual = (index > 1) ? indexAtual : index;
    switch(index){
      case 0:
        setState(() {
          paginaAtual = const HomePage();
        });
        break;
      case 1:
        setState(() {
          paginaAtual = TecnicoPage(
              onFabPressed: () {changePage(2);},
              onEditPressed: (idUpdate) {changePage(3, id: idUpdate);}
          );
        });
        break;
      case 2:
        setState(() {
          paginaAtual = CreateTecnico(onIconPressed: () {changePage(1);});
        });
        break;
      case 3:
        setState(() {
          paginaAtual = UpdateTecnico(onIconPressed: () {changePage(1);}, id: id!);
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
