import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/pagination_widget.dart';
import 'package:serv_oeste/src/components/screen/cards/card_user.dart';
import 'package:serv_oeste/src/components/screen/entity_not_found.dart';
import 'package:serv_oeste/src/components/screen/error_component.dart';
import 'package:serv_oeste/src/components/screen/loading.dart';
import 'package:serv_oeste/src/screens/user/create_user.dart';
import 'package:serv_oeste/src/screens/user/update_user.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/models/user/user.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(LoadUsersEvent());
    });
  }

  void _onCreateUser() {
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => CreateUserScreen(),
      ),
    )
        .then((_) {
      if (mounted) {
        context.read<UserBloc>().add(LoadUsersEvent());
      }
    });
  }

  void _onEditUser(User user) {
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => UpdateUserScreen(
          userId: user.id,
          currentUsername: user.username,
          currentRole: user.role,
        ),
      ),
    )
        .then((_) {
      if (mounted) {
        context.read<UserBloc>().add(LoadUsersEvent());
      }
    });
  }

  void _onDeleteUser(String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              Text('Tem certeza que deseja excluir o usuário "$username"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<UserBloc>()
                    .add(DeleteUserEvent(username: username));
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;

    if (isLargeScreen) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Usuários do Sistema',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _onCreateUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: const Icon(Icons.person_add, size: 20),
            label: const Text(
              'Novo Usuário',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Usuários do Sistema',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _onCreateUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.person_add, size: 20),
            label: const Text(
              'Novo Usuário',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }
  }

  EdgeInsets _getResponsivePadding() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    if (isMobile) {
      return const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0);
    } else {
      return const EdgeInsets.only(right: 16.0, bottom: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: _getResponsivePadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<UserBloc>().add(LoadUsersEvent());
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.detail),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is UserLoading) {
          return const Loading();
        } else if (state is UserLoaded) {
          final nonAdminUsers = state.users.content
              .where((user) => user.role != 'ADMIN')
              .toList();

          if (nonAdminUsers.isEmpty) {
            return const EntityNotFound(
              message: "Nenhum usuário cadastrado",
              icon: Icons.people_outline,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: nonAdminUsers.length,
                  itemBuilder: (context, index) {
                    final user = nonAdminUsers[index];
                    return UserCard(
                      user: user,
                      onEdit: () => _onEditUser(user),
                      onDelete: () => _onDeleteUser(user.username),
                      showDeleteButton: true,
                    );
                  },
                ),
              ),
              if (state.users.page.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: PaginationWidget(
                    currentPage: state.users.page.page + 1,
                    totalPages: state.users.page.totalPages,
                    onPageChanged: (page) {
                      context
                          .read<UserBloc>()
                          .add(LoadUsersEvent(page: page - 1));
                    },
                  ),
                ),
            ],
          );
        } else if (state is UserOperationLoading) {
          return const Loading();
        }
        return const ErrorComponent();
      },
    );
  }
}
