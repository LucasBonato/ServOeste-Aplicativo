import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/bottom_nav_bar.dart';
import 'package:serv_oeste/src/components/layout/header.dart';
import 'package:serv_oeste/src/components/layout/sidebar_navigation.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/screens/auth/login.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/home.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico.dart';
import 'package:serv_oeste/src/screens/user/user.dart';
import 'package:serv_oeste/src/utils/jwt_utils.dart';
import 'package:serv_oeste/src/services/secure_storage_service.dart';

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
  int _currentIndex = 0;
  List<GlobalKey<NavigatorState>> _navigatorKeys = [];
  List<Widget?> _screens = [];

  int _maxIndex = 4;
  String? _userRole;
  bool _isInitialized = false;

  late final ServicoBloc _servicoBloc;
  late final TecnicoBloc _tecnicoBloc;
  late final ClienteBloc _clienteBloc;
  late final UserBloc _userBloc;
  Timer? _authTimer;

  @override
  void initState() {
    super.initState();
    _servicoBloc = context.read<ServicoBloc>();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _clienteBloc = context.read<ClienteBloc>();
    _userBloc = context.read<UserBloc>();

    _currentIndex = widget.initialIndex ?? 0;

    _navigatorKeys = [];
    _screens = [];

    _initializeUserRole().then((_) {
      _initializeLists();
      _loadTab(_currentIndex);
    });
  }

  Future<void> _initializeUserRole() async {
    final token = await SecureStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final decodedToken = decodeJwt(token);
      if (decodedToken != null) {
        final newRole = decodedToken['role'] as String?;
        final isAdmin = newRole == 'ROLE_ADMIN';
        final newMaxIndex = isAdmin ? 5 : 4;

        if (mounted) {
          setState(() {
            _userRole = newRole;
            _maxIndex = newMaxIndex;
          });
        }
      }
    }
  }

  void _initializeLists() {
    if (mounted) {
      setState(() {
        _navigatorKeys =
            List.generate(_maxIndex, (_) => GlobalKey<NavigatorState>());
        _screens = List.filled(_maxIndex, null);
        _isInitialized = true;
      });
    }
  }

  bool get _isAdmin => _userRole == 'ROLE_ADMIN';

  @override
  void dispose() {
    _authTimer?.cancel();
    super.dispose();
  }

  Widget _getScreen(int index) {
    if (index >= _maxIndex || !_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_screens[index] != null) {
      return _screens[index]!;
    }

    _screens[index] = switch (index) {
      0 => BlocProvider.value(value: _servicoBloc, child: Home(key: UniqueKey())),
      1 => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _tecnicoBloc),
            BlocProvider(create: (_) => ListaBloc()..add(ListaClearEvent())),
          ],
          child: TecnicoScreen(key: UniqueKey()),
        ),
      2 => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _clienteBloc),
            BlocProvider(create: (_) => ListaBloc()..add(ListaClearEvent())),
          ],
          child: ClienteScreen(key: UniqueKey()),
        ),
      3 => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _servicoBloc),
            BlocProvider(create: (_) => ListaBloc()..add(ListaClearEvent())),
          ],
          child: ServicoScreen(key: UniqueKey()),
        ),
      4 when _isAdmin => BlocProvider.value(
          value: _userBloc,
          child: UserScreen(key: UniqueKey()),
        ),
      _ => Container()
    };

    return _screens[index]!;
  }

  void _selectTab(int index) {
    if (index >= _maxIndex || !_isInitialized) return;

    if (_currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
      _loadTab(index);
    }
  }

  void _loadTab(int index) {
    if (!_isInitialized) return;

    final Map<int, VoidCallback> tabLoadAction = {
      0: _loadHome,
      1: _loadTecnico,
      2: _loadCliente,
      3: _loadServico,
      4: _loadUser,
    };
    tabLoadAction[index]?.call();
  }

  void _loadHome() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime week = startOfDay.add(Duration(days: 7));

    context.read<ServicoBloc>().add(
          ServicoInitialLoadingEvent(
            filterRequest: ServicoFilterRequest(
              dataAtendimentoPrevistoAntes: startOfDay,
              dataAtendimentoPrevistoDepois: week,
            ),
            page: 0,
            size: 10,
          ),
        );
  }

  void _loadTecnico() {
    _tecnicoBloc.add(TecnicoSearchMenuEvent());
  }

  void _loadCliente() {
    _clienteBloc.add(ClienteSearchMenuEvent());
  }

  void _loadServico() {
    _servicoBloc.add(ServicoSearchMenuEvent());
  }

  void _loadUser() {
    _userBloc.add(LoadUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 800;

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnauthenticatedState || state is AuthLogoutSuccessState) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            if (isLargeScreen)
              SidebarNavigation(
                currentIndex: _currentIndex,
                onSelect: _selectTab,
                userRole: _userRole,
              ),
            Expanded(
              child: Column(
                children: [
                  HeaderComponent(
                    onLogout: () {
                      context.read<AuthBloc>().add(AuthLogoutEvent());
                    },
                  ),
                  Expanded(
                    child: Stack(
                      children: List.generate(_maxIndex, (index) {
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
                userRole: _userRole,
              ),
      ),
    );
  }
}
