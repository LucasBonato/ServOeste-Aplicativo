import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/models/user/user_form.dart';
import 'package:serv_oeste/src/models/validators/user_validator.dart';
import 'package:serv_oeste/src/screens/user/user_form.dart';
import 'package:serv_oeste/src/utils/extensions/role_extensions.dart';

class UpdateUserScreen extends StatefulWidget {
  final int userId;
  final String currentUsername;
  final String currentRole;

  const UpdateUserScreen({
    super.key,
    required this.userId,
    required this.currentUsername,
    required this.currentRole,
  });

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userForm = UserForm();
  final _validator = UserValidator();

  @override
  void initState() {
    super.initState();
    _userForm.setId(widget.userId);
    _userForm.setUsername(widget.currentUsername);
    _userForm.setRole(widget.currentRole);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userBloc = context.read<UserBloc>();
    final String backendRole = _userForm.role.value.toBackendRole();

    userBloc.add(UpdateUserEvent(
      id: _userForm.id!,
      username: _userForm.username.value,
      password: _userForm.password.value,
      role: backendRole,
    ));
  }

  @override
  void dispose() {
    _userForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBarForm(
        title: 'Editar Usuário',
        onPressed: () => Navigator.pop(context, "Back"),
        shouldActivateEvent: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: UserFormWidget(
                userForm: _userForm,
                validator: _validator,
                formKey: _formKey,
                isUpdate: true,
                submitText: 'Atualizar Usuário',
                successMessage: 'Usuário atualizado com sucesso!',
                onSubmit: _submitForm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
