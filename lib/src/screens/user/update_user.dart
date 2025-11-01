import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/models/auth/auth_form.dart';
import 'package:serv_oeste/src/models/validators/auth_validator.dart';
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
  final _authForm = AuthForm();
  final _validator = AuthValidator();

  @override
  void initState() {
    super.initState();
    _authForm.setUsername(widget.currentUsername);
    _authForm.setRole(widget.currentRole);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authBloc = context.read<AuthBloc>();
    final String backendRole = _authForm.role.value.toBackendRole();

    // authBloc.add(AuthUpdateEvent(
    //   userId: widget.userId,
    //   username: _authForm.username.value,
    //   role: backendRole,
    // ));
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
                authForm: _authForm,
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
