import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
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
                        CustomTextFormField(
                          label: 'Nome de Usuário*',
                          hint: 'Digite o nome de usuário',
                          leftPadding: 0,
                          rightPadding: 0,
                          hide: true,
                          maxLength: 255,
                          type: TextInputType.name,
                          valueNotifier: _authForm.username,
                          validator: _validator.byField(
                              _authForm, ErrorCodeKey.username.name),
                          onChanged: _authForm.setUsername,
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          label: 'Senha*',
                          hint: 'Digite a senha',
                          leftPadding: 0,
                          rightPadding: 0,
                          hide: true,
                          maxLength: 24,
                          type: TextInputType.name,
                          valueNotifier: _authForm.password,
                          validator: _validator.byField(
                              _authForm, ErrorCodeKey.password.name),
                          onChanged: _authForm.setPassword,
                        ),
                        const SizedBox(height: 20),
                        CustomDropdownFormField(
                          label: 'Cargo*',
                          leftPadding: 0,
                          rightPadding: 0,
                          valueNotifier: _authForm.role,
                          onChanged: _authForm.setRole,
                          dropdownValues: Constants.roleUserDisplayList,
                          validator: _validator.byField(
                              _authForm, ErrorCodeKey.role.name),
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
                              backgroundColor: Color(0xFF007BFF),
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
