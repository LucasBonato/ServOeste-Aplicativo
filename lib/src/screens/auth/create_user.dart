import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/models/auth/auth_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/auth_validator.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';
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

  @override
  void dispose() {
    _authForm.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authBloc = context.read<AuthBloc>();

      final String backendRole = _authForm.role.value.toBackendRole();

      authBloc.add(AuthRegisterEvent(
        username: _authForm.username.value,
        password: _authForm.password.value,
        role: backendRole,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário criado com sucesso!')),
      );

      Navigator.pop(context);
    }
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _authForm.username,
                          builder: (context, username, child) {
                            return TextFormField(
                              onChanged: _authForm.setUsername,
                              decoration: InputDecoration(
                                labelText: 'Nome de Usuário*',
                                hintText: 'Digite o nome de usuário',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (value) => _validator.byField(
                                  _authForm, ErrorCodeKey.user.name)(value),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder(
                          valueListenable: _authForm.password,
                          builder: (context, password, child) {
                            return TextFormField(
                              onChanged: _authForm.setPassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Senha*',
                                hintText: 'Digite a senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (value) => _validator.byField(
                                  _authForm, ErrorCodeKey.user.name)(value),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder(
                          valueListenable: _authForm.role,
                          builder: (context, role, child) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Cargo*',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _authForm.role.value.isEmpty
                                      ? Constants.roleUserDisplayList.first
                                      : _authForm.role.value,
                                  isExpanded: true,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  items: Constants.roleUserDisplayList
                                      .map((String roleDisplay) {
                                    return DropdownMenuItem<String>(
                                      value: roleDisplay,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(roleDisplay),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _authForm.setRole(newValue);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        BlocListener<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthErrorState) {
                              _validator.applyBackendError(state.error);
                              _formKey.currentState?.validate();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.error.errorMessage),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            } else if (state is AuthRegisterSuccessState) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Usuário criado com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Criar Usuário',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
