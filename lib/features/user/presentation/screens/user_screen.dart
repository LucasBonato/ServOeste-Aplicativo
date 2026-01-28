import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/core/routing/routes.dart';
import 'package:serv_oeste/features/user/domain/entities/user_response.dart';
import 'package:serv_oeste/shared/models/enums/list_style.dart';
import 'package:serv_oeste/shared/widgets/layout/fab_add.dart';
import 'package:serv_oeste/features/user/presentation/widgets/user_card.dart';
import 'package:serv_oeste/shared/widgets/screen/error_component.dart';
import 'package:serv_oeste/features/user/presentation/bloc/user_bloc.dart';
import 'package:serv_oeste/shared/widgets/screen/base_list_screen.dart';
import 'package:serv_oeste/features/user/presentation/screens/user_create_screen.dart';
import 'package:serv_oeste/features/user/presentation/screens/user_update_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserScreen extends BaseListScreen<UserResponse> {
  const UserScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UserScreenTestState();
}

class _UserScreenTestState extends BaseListScreenState<UserResponse> {
  late final UserBloc _userBloc;
  late String username;
  late String role;

  EdgeInsets _getResponsivePadding() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    if (isMobile) {
      return const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0);
    }
    return const EdgeInsets.only(right: 16.0, bottom: 16.0);
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Usuários do Sistema',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _onDeleteUser(String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o usuário "$username"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[800])),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _userBloc.add(DeleteUserEvent(username: username));
              },
              style: TextButton.styleFrom(overlayColor: Colors.red),
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildDefaultFloatingActionButton()
    => FloatingActionButtonAdd(
      route: Routes.userCreate,
      event: () => _userBloc.add(LoadUsersEvent()),
      tooltip: "Adicionar Usuário",
    );

  @override
  Widget buildItemCard(UserResponse item, bool isSelected, bool isSelectMode, bool isSkeleton) {
    return UserCard(
      user: item,
      onEdit: () {
        username = item.username!;
        role = item.role!;
        onNavigateToUpdateScreen(item.id!, () => _userBloc.add(LoadUsersEvent()));
      },
      onDelete: () => _onDeleteUser(item.username!),
      showDeleteButton: true,
    );
  }

  @override
  Widget buildSelectionFloatingActionButton(List<int> selectedIds) => throw UnimplementedError();

  @override
  Widget getCreateScreen() => CreateUserScreen();

  @override
  Widget getUpdateScreen(int id, {int? secondId}) => UpdateUserScreen(id: id, username: username, role: role);

  @override
  void onDisableItems(List<int> selectedIds) => throw UnimplementedError();

  @override
  void searchFieldChanged() => throw UnimplementedError();

  @override
  void initState() {
    super.initState();
    _userBloc = context.read<UserBloc>();
    setListStyle(ListStyle.list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: buildDefaultFloatingActionButton(),
      body: Padding(
        padding: _getResponsivePadding(),
        child: Column(children: [
          _buildHeaderSection(),
          Expanded(
            child: BlocConsumer<UserBloc, UserState>(
              listenWhen: (previous, current) => current is UserErrorState || current is UserDeletedState,
              listener: (context, state) {
                if (state is UserDeletedState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário excluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _userBloc.add(LoadUsersEvent());
                } else if (state is UserErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error.detail),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, userState) {
                if (userState is UserInitialState || userState is UserLoadingState) {
                  return Skeletonizer(
                    enableSwitchAnimation: true,
                    child: buildGridOfCards(
                      items: List.generate(10, (_) => UserResponse()..applySkeletonData()),
                      aspectRatio: 1,
                      totalPages: 1,
                      currentPage: 0,
                      onPageChanged: (_) {},
                      isSkeleton: true,
                    ),
                  );
                } else if (userState is UserLoadedState) {
                  final List<UserResponse> users = userState.users.where((user) => user.role != "ADMIN").toList();
                  return buildGridOfCards(
                    items: users,
                    aspectRatio: 1,
                    totalPages: userState.totalPages,
                    currentPage: userState.currentPage,
                    onPageChanged: (page) {
                      _userBloc.add(LoadUsersEvent(page: page - 1));
                    },
                  );
                }
                return const ErrorComponent();
              },
            ),
          ),
        ]),
      ),
    );
  }
}
