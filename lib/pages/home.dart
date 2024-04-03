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
