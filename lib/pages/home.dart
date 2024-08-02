import 'package:flutter/material.dart';
import 'package:serv_oeste/pages/cliente/cliente.dart';
import 'package:serv_oeste/pages/tecnico/tecnico.dart';
import 'package:serv_oeste/pages/cliente/create_cliente.dart';
import 'package:serv_oeste/pages/cliente/update_cliente.dart';
import 'package:serv_oeste/pages/tecnico/create_tecnico.dart';
import 'package:serv_oeste/pages/tecnico/update_tecnico.dart';

Widget home = Column(
  mainAxisSize: MainAxisSize.max,
  children: [
    Expanded(
      child: Align(
        alignment: const AlignmentDirectional(0, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'images/servOeste.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0),
          ),
        ),
      ),
    ),
  ],
);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int indexAtual = 0;
  int _idUpdate = 0;
  late List<Widget> paginas;
  late Widget clientePage;
  late Widget tecnicoPage;

  @override
  void initState() {
    super.initState();
    clientePage = ClientePage(
      onFabPressed: () {
        setState(() {
          indexAtual = 3;
        });
      },
      onEditPressed: (idUpdate) {
        setState(() {
          indexAtual = 4;
          _idUpdate = idUpdate;
        });
      },
    );
    tecnicoPage = TecnicoPage(
      onFabPressed: () {
        setState(() {
          indexAtual = 5;
        });
      },
      onEditPressed: (idUpdate) {
        setState(() {
          indexAtual = 6;
          _idUpdate = idUpdate;
        });
      },
    );
    paginas = [
      clientePage,
      home,
      tecnicoPage,
      CreateCliente(onIconPressed: () {
        setState(() {
          indexAtual = 0;
        });
      }),
      UpdateCliente(onIconPressed: () {
        setState(() {
          indexAtual = 0;
        });
      }, id: _idUpdate),
      CreateTecnico(onIconPressed: () {
        setState(() {
          indexAtual = 2;
        });
      }),
      UpdateTecnico(onIconPressed: () {
        setState(() {
          indexAtual = 2;
        });
      }, id: _idUpdate),
    ];
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
			body: IndexedStack(
        index: indexAtual,
        children: paginas,
      ),
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
        onTap: (index) => indexAtual = index,
      ),
		);
	}
}
