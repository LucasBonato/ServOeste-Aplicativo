import 'package:flutter/material.dart';
import 'package:serv_oeste/pages/cliente/cliente.dart';
import 'package:serv_oeste/pages/tecnico/tecnico.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  late PersistentTabController _persistentController;
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController()
  ];
  List<Widget> _paginas() => [
    const ClientePage(),
    Column(
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
    ), // Home
    const TecnicoPage()
  ];
  List<PersistentBottomNavBarItem> _navBarItens() => [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.account_circle_outlined, size: 40),
      title: "Clientes",
      textStyle: const TextStyle(fontSize: 15),
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.black,
      scrollController: _scrollControllers.first
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home_outlined, size: 45),
      title: "Home",
      textStyle: const TextStyle(fontSize: 15),
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.black,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.attribution, size: 40),
      title: "Técnicos",
        textStyle: const TextStyle(fontSize: 15),
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.black,
      scrollController: _scrollControllers.last
    ),
  ];

  @override
  void initState() {
    super.initState();
    _persistentController = PersistentTabController(initialIndex: 1);
  }

  @override
  void dispose() {
    for(final scrollController in _scrollControllers) {
      scrollController.dispose();
    }
    super.dispose();
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
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20)
          )
        ),
      ),
			body: PersistentTabView(
        context,
        controller: _persistentController,
        hideNavigationBarWhenKeyboardAppears: true,
        screens: _paginas(),
        items: _navBarItens(),
        navBarStyle: NavBarStyle.simple,
        navBarHeight: 65,
        bottomScreenMargin: 65,
        animationSettings: const NavBarAnimationSettings(
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            animateTabTransition: true,
            duration: Duration(milliseconds: 200),
            screenTransitionAnimationType: ScreenTransitionAnimationType.slide
          )
        ),
        padding: const EdgeInsets.only(bottom: 5),
        decoration: const NavBarDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)
          ),
          colorBehindNavBar: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 99),
              offset: Offset(0, -5),
              spreadRadius: -5,
              blurRadius: 20
            )
          ]
        ),
      )
		);
	}
}