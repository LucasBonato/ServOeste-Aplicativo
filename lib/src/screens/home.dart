import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:serv_oeste/src/components/sidebar_navigation.dart';
import 'package:serv_oeste/src/components/card_service.dart';
import 'package:serv_oeste/src/components/header.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PersistentTabController _persistentController;

  final List<dynamic> dataList = [
    {
      'id': 1,
      'cliente': "Jefferson Oliveira",
      'equipamento': "Geladeira",
      'marca': "Consul",
      'tecnico': "Lucas Adriano",
      'local': "Osasco",
      'data': "11/11/2024 - Tarde",
      'status': "Aguardando Orçamento"
    },
    {
      'id': 2,
      'cliente': "Carlos Silva",
      'equipamento': "Ar Condicionado",
      'marca': "Samsung",
      'tecnico': "João",
      'local': "São Paulo",
      'data': "12/11/2024 - Manhã",
      'status': "Orçamento Aprovado"
    },
    {
      'id': 3,
      'cliente': "Maria Souza",
      'equipamento': "Micro-ondas",
      'marca': "LG",
      'tecnico': "Pedro",
      'local': "São Bernardo do Campo",
      'data': "12/11/2024 - Tarde",
      'status': "Aguardando Agendamento"
    },
    {
      'id': 4,
      'cliente': "Luciana Mendes",
      'equipamento': "Máquina de Lavar",
      'marca': "Brastemp",
      'tecnico': "Marcos",
      'local': "Guarulhos",
      'data': "13/11/2024 - Manhã",
      'status': "Aguardando Aprovação do Cliente"
    },
    {
      'id': 5,
      'cliente': "Gustavo Lima",
      'equipamento': "Secadora de Roupas",
      'marca': "Electrolux",
      'tecnico': "Ana Paula",
      'local': "Osasco",
      'data': "13/11/2024 - Tarde",
      'status': "Aguardando Orçamento"
    },
    {
      'id': 6,
      'cliente': "Fabiana Rocha",
      'equipamento': "Geladeira",
      'marca': "Eletrolux",
      'tecnico': "João",
      'local': "São Paulo",
      'data': "14/11/2024 - Manhã",
      'status': "Orçamento Aprovado"
    },
    {
      'id': 7,
      'cliente': "José Almeida",
      'equipamento': "Fogão",
      'marca': "Atlas",
      'tecnico': "Carlos",
      'local': "Santos",
      'data': "14/11/2024 - Tarde",
      'status': "Aguardando Atendimento"
    },
    {
      'id': 8,
      'cliente': "Patricia Lima",
      'equipamento': "Micro-ondas",
      'marca': "Panasonic",
      'tecnico': "Luana",
      'local': "Sorocaba",
      'data': "15/11/2024 - Manhã",
      'status': "Aguardando Cliente Retirar"
    },
    {
      'id': 9,
      'cliente': "Roberto Oliveira",
      'equipamento': "Ar Condicionado",
      'marca': "Midea",
      'tecnico': "Bruno",
      'local': "São Caetano do Sul",
      'data': "15/11/2024 - Tarde",
      'status': "Resolvido"
    },
    {
      'id': 10,
      'cliente': "Ana Costa",
      'equipamento': "Máquina de Lavar",
      'marca': "Samsung",
      'tecnico': "Ricardo",
      'local': "Ribeirão Preto",
      'data': "16/11/2024 - Manhã",
      'status': "Aguardando Orçamento"
    },
  ];

  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  @override
  void initState() {
    super.initState();
    _persistentController = PersistentTabController(initialIndex: 2);
  }

  @override
  void dispose() {
    for (final scrollController in _scrollControllers) {
      scrollController.dispose();
    }
    super.dispose();
  }

  List<Widget> _buildScreens() => [
        const Servico(),
        const ClientePage(),
        _buildHomeScreen(),
        const TecnicoPage(),
      ];

  List<PersistentBottomNavBarItem> _navBarItems() => [
        _buildNavBarItem(
          icon: Icons.content_paste,
          title: "Serviços",
          scrollController: _scrollControllers.first,
        ),
        _buildNavBarItem(
          icon: Icons.people,
          title: "Clientes",
        ),
        _buildNavBarItem(
          icon: Icons.home,
          title: "Home",
        ),
        _buildNavBarItem(
          icon: Icons.build,
          title: "Técnicos",
          scrollController: _scrollControllers.last,
        ),
      ];

  PersistentBottomNavBarItem _buildNavBarItem({
    required IconData icon,
    required String title,
    double size = 35,
    ScrollController? scrollController,
  }) {
    return PersistentBottomNavBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: size),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.black,
      scrollController: scrollController,
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderComponent(),
            const SizedBox(height: 20),
            Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/heroImage3.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Text(
                "Agenda do Dia",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            GridListView(
              dataList: dataList, // Passando a lista de dados
              buildCard:
                  _buildAgendaCard, // Passando a função de construção do card
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard(dynamic data) {
    return CardService(
      cliente: data['cliente'],
      equipamento: data['equipamento'],
      marca: data['marca'],
      tecnico: "Técnico - ${data['tecnico']}",
      local: data['local'],
      data: data['data'],
      status: data['status'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 768;

    if (isLargeScreen) {
      return Scaffold(
        body: Row(
          children: [
            const SidebarNavigation(currentIndex: 0),
            Expanded(
              child: IndexedStack(
                index: _persistentController.index,
                children: _buildScreens(),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: PersistentTabView(
          context,
          controller: _persistentController,
          screens: _buildScreens(),
          items: _navBarItems(),
          navBarStyle: NavBarStyle.style6,
          navBarHeight: 75,
          decoration: const NavBarDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            colorBehindNavBar: Colors.transparent,
          ),
          hideNavigationBarWhenKeyboardAppears: true,
        ),
      );
    }
  }
}
