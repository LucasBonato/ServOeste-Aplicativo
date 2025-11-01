import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/models/auth/auth_form.dart';
import 'package:serv_oeste/src/models/validators/auth_validator.dart';
import 'package:serv_oeste/src/screens/user/user_form.dart';
import 'package:serv_oeste/src/utils/extensions/role_extensions.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authForm = AuthForm();
  final _validator = AuthValidator();

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authBloc = context.read<AuthBloc>();
    final String backendRole = _authForm.role.value.toBackendRole();

    authBloc.add(AuthRegisterEvent(
      username: _authForm.username.value,
      password: _authForm.password.value,
      role: backendRole,
    ));
  }

  @override
  void dispose() {
    _authForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBarForm(
        title: 'Adicionar Usuário',
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
                authForm: _authForm,
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
