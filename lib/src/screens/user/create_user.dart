import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/models/user/user_form.dart';
import 'package:serv_oeste/src/models/validators/user_validator.dart';
import 'package:serv_oeste/src/screens/user/user_form.dart';
import 'package:serv_oeste/src/utils/extensions/role_extensions.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userForm = UserForm();
  final _validator = UserValidator();

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userBloc = context.read<UserBloc>();
    final String backendRole = _userForm.role.value.toBackendRole();

    userBloc.add(CreateUserEvent(
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
        title: 'Adicionar Usuário',
        onPressed: () => Navigator.pop(context),
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
                isUpdate: false,
                submitText: 'Criar Usuário',
                successMessage: 'Usuário criado com sucesso!',
                onSubmit: _submitForm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
