import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/pagination_widget.dart';
import 'package:serv_oeste/src/components/screen/entity_not_found.dart';
import 'package:serv_oeste/src/components/screen/error_component.dart';
import 'package:serv_oeste/src/components/screen/loading.dart';
import 'package:serv_oeste/src/screens/user/create_user.dart';

// import 'package:serv_oeste/src/logic/user/user_bloc.dart';
// import 'package:serv_oeste/src/models/user/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    // context.read<UserBloc>().add(LoadUsersEvent());
  }

  void _onCreateUser() {
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => CreateUserScreen(),
      ),
    )
        .then((_) {
      // context.read<UserBloc>().add(LoadUsersEvent());
    });
  }

  void _onEditUser(String userId) {
    // Navigator.of(context, rootNavigator: true).push(
    //   MaterialPageRoute(
    //     builder: (context) => EditUserScreen(userId: userId),
    //   ),
    // ).then((_) {
    //   context.read<UserBloc>().add(LoadUsersEvent());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
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
                    backgroundColor: Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: Icon(Icons.person_add, size: 20),
                  label: const Text(
                    'Novo Usuário',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Funcionalidade em Desenvolvimento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'lista de usuários',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    /*
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadingState) {
          return const Loading();
        } else if (state is UserLoadedState) {
          if (state.users.isEmpty) {
            return const EntityNotFound(
              message: "Nenhum usuário cadastrado",
              icon: Icons.people_outline,
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.role),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _onEditUser(user.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: PaginationWidget(
                    currentPage: state.currentPage + 1,
                    totalPages: state.totalPages,
                    onPageChanged: (page) {
                      context.read<UserBloc>().add(LoadUsersEvent(page: page - 1));
                    },
                  ),
                ),
            ],
          );
        }
        return const ErrorComponent();
      },
    );
    */
  }
}
