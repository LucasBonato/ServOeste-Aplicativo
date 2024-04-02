import 'package:flutter/material.dart';
import 'package:serv_oeste/pages/home_page.dart';
import 'package:serv_oeste/pages/tecnico_page.dart';

class Home extends StatefulWidget {
	const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int indexAtual = 0;
  Widget paginaAtual = const HomePage();

  List<BottomNavigationBarItem> putingItensInNav(){
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.attribution),
        label: "Técnico"
      ),
      ];
  }

  void changePage(int index){
    setState(() {
      indexAtual = index;
      switch(index){
        case 0: paginaAtual = const HomePage();
        case 1: paginaAtual = const TecnicoPage();
      }
    });
  }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('ServOeste'),
        actions: [],
        centerTitle: true,
        elevation: 4,
      ),
			body: paginaAtual,
      bottomNavigationBar: BottomNavigationBar(
        items: putingItensInNav(),
        currentIndex: indexAtual,
        onTap: (index) => changePage(index),
      ),
		);
	}
}
