import 'package:flutter/material.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:serv_oeste/src/components/sidebar_navigation.dart';
import 'package:serv_oeste/src/components/card_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PersistentTabController _persistentController;

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
        _buildHomeScreen(), // Substituído para refletir o design
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
    double size = 40,
    ScrollController? scrollController,
  }) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon, size: size),
      title: title,
      textStyle: const TextStyle(fontSize: 15),
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
            // Header ajustado
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 45,
                        maxHeight: 50,
                      ),
                      child: Image.asset(
                        'assets/servOeste.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Hero com overlay e imagem com maxHeight
            Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300, // Definindo a altura máxima
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
                          color: Colors.grey),
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600
                    ? MediaQuery.of(context).size.width * 0.02
                    : 30,
                vertical: 10,
              ),
              child: GridView.builder(
                itemCount: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 1400
                      ? 4
                      : MediaQuery.of(context).size.width > 1000
                          ? 3
                          : MediaQuery.of(context).size.width > 600
                              ? 2
                              : 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2,
                ),
                itemBuilder: (context, index) {
                  return _buildAgendaCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard() {
    return const CardServiceAgenda(
      cliente: "Jefferson Oliveira",
      equipamento: "Geladeira - Consul",
      tecnico: "Técnico - Lucas Adriano",
      local: "Osasco",
      data: "11/11/2024 - Tarde",
      status: "Aguardando Orçamento",
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 768;

    if (!isLargeScreen) {
      // Modo Mobile: Ajustando para evitar dois headers
      return Scaffold(
        body: PersistentTabView(
          context,
          controller: _persistentController,
          screens: _buildScreens(),
          items: _navBarItems(),
          navBarStyle: NavBarStyle.style6,
          navBarHeight: 70,
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
    } else {
      // Modo Desktop: Sidebar com header fixo
      return Scaffold(
        body: Row(
          children: [
            const SidebarNavigation(),
            Expanded(
              child: IndexedStack(
                index: _persistentController.index,
                children: _buildScreens(),
              ),
            ),
          ],
        ),
      );
    }
  }
}
