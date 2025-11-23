import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/models/user/user_form.dart';
import 'package:serv_oeste/src/screens/user/user_from.dart';
import 'package:serv_oeste/src/utils/extensions/role_extensions.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserBloc bloc = context.read<UserBloc>();
    final UserForm userForm = UserForm();

    return UserFormPage(
      title: "Adicionar Usuário",
      submitText: "Adicionar Usuário",
      successMessage: "Usuário criado com sucesso!",
      bloc: bloc,
      userForm: userForm,
      onSubmit: () {
        final String backendRole = userForm.role.value.toBackendRole();

        bloc.add(CreateUserEvent(
          username: userForm.username.value,
          password: userForm.password.value,
          role: backendRole,
        ));
      },
    );
  }
}
