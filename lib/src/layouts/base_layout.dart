import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/bottom_navBar.dart';
import 'package:serv_oeste/src/components/sidebar_navigation.dart';
import 'package:serv_oeste/src/components/header.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/home.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico.dart';

class BaseLayout extends StatefulWidget {
  final int initialIndex;

  const BaseLayout({
    super.key,
    required this.initialIndex,
  });

  @override
  _BaseLayoutState createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  late int _currentIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];
  late List<Widget?> _screens;

  final _servicoBloc = ServicoBloc();
  final _tecnicoBloc = TecnicoBloc();
  final _clienteBloc = ClienteBloc();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _navigatorKeys.addAll(List.generate(4, (_) => GlobalKey<NavigatorState>()));
    _screens = List.filled(4, null);

    _handleTabLoad(_currentIndex);
  }

  Widget _buildScreen(int index) {
    if (_screens[index] == null) {
      switch (index) {
        case 0:
          _screens[index] = Home();
          break;
        case 1:
          _screens[index] = TecnicoScreen();
          break;
        case 2:
          _screens[index] = ClienteScreen();
          break;
        case 3:
          _screens[index] = ServicesScreen();
          break;
        default:
          _screens[index] = Container();
      }
    }
    return _screens[index]!;
  }

  void _selectTab(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });

      // Disparar a requisição ao mudar de aba
      _handleTabLoad(index);
    }
  }

  void _handleTabLoad(int index) {
    if (index == 0) {
      _onNavigateToHome();
    } else if (index == 1) {
      _onNavigateToTecnico();
    } else if (index == 2) {
      _onNavigateToCliente();
    } else if (index == 3) {
      _onNavigateToServico();
    }
  }

  void _onNavigateToHome() {
    _servicoBloc.add(ServicoLoadingEvent(
        filterRequest: ServicoFilterRequest(
            // dataAtendimentoPrevistoAntes: DateTime.now().toUtc()
            )));
  }

  void _onNavigateToTecnico() {
    _tecnicoBloc.add(TecnicoLoadingEvent());
  }

  void _onNavigateToCliente() {
    _clienteBloc.add(ClienteLoadingEvent());
  }

  void _onNavigateToServico() {
    _servicoBloc.add(ServicoLoadingEvent(
      filterRequest: ServicoFilterRequest(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 800;

    return Scaffold(
      body: Row(
        children: [
          if (isLargeScreen)
            SidebarNavigation(
              currentIndex: _currentIndex,
              onSelect: _selectTab,
            ),
          Expanded(
            child: Column(
              children: [
                const HeaderComponent(),
                Expanded(
                  child: Stack(
                    children: List.generate(4, (index) {
                      return Offstage(
                        offstage: _currentIndex != index,
                        child: Navigator(
                          key: _navigatorKeys[index],
                          onGenerateRoute: (_) => MaterialPageRoute(
                            builder: (context) => _buildScreen(index),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _selectTab,
            ),
    );
  }
}
