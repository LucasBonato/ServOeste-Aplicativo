import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/bottom_nav_bar.dart';
import 'package:serv_oeste/src/components/sidebar_navigation.dart';
import 'package:serv_oeste/src/components/header.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/home.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class BaseLayout extends StatefulWidget {
  final int? initialIndex;

  const BaseLayout({
    super.key,
    this.initialIndex,
  });

  @override
  BaseLayoutState createState() => BaseLayoutState();
}

class BaseLayoutState extends State<BaseLayout> {
  late int _currentIndex;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;
  late final List<Widget?> _screens;

  late final ServicoBloc _servicoBloc;
  late final TecnicoBloc _tecnicoBloc;
  late final ClienteBloc _clienteBloc;

  @override
  void initState() {
    super.initState();
    _servicoBloc = context.read<ServicoBloc>();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _clienteBloc = context.read<ClienteBloc>();

    _currentIndex = widget.initialIndex ?? 0;
    _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());
    _screens = List.filled(4, null);
    _loadTab(_currentIndex);
  }

  Widget _getScreen(int index) {
    _screens[index] ??= switch (index) {
      0 => BlocProvider.value(value: _servicoBloc, child: Home()),
      1 => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _tecnicoBloc),
            BlocProvider(create: (_) => ListaBloc()..add(ListaInitialEvent()))
          ],
          child: TecnicoScreen(),
        ),
      2 => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _clienteBloc),
            BlocProvider(create: (_) => ListaBloc()..add(ListaInitialEvent()))
          ],
          child: ClienteScreen(),
        ),
      3 => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _servicoBloc),
            BlocProvider(create: (_) => ListaBloc()..add(ListaInitialEvent())),
          ],
          child: ServicoScreen(),
        ),
      _ => Container()
    };
    return _screens[index]!;
  }

  void _selectTab(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
      _loadTab(index);
    }
  }

  void _loadTab(int index) {
    final Map<int, VoidCallback> tabLoadAction = {
      0: _loadHome,
      1: _loadTecnico,
      2: _loadCliente,
      3: _loadServico
    };
    tabLoadAction[index]?.call();
  }

  void _loadHome() {
    DateTime today = DateTime.now();

    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime week = startOfDay.add(Duration(days: 7));

    _servicoBloc.add(
      ServicoInitialLoadingEvent(
        filterRequest: ServicoFilterRequest(
          dataAtendimentoPrevistoAntes: startOfDay,
          dataAtendimentoPrevistoDepois: week,
        ),
      ),
    );
  }

  void _loadTecnico() {
    _tecnicoBloc.add(
        TecnicoLoadingEvent(situacao: Constants.situationTecnicoList.first));
  }

  void _loadCliente() {
    _clienteBloc.add(ClienteLoadingEvent());
  }

  void _loadServico() {
    _servicoBloc.add(ServicoInitialLoadingEvent(
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
                            builder: (context) => _getScreen(index),
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
