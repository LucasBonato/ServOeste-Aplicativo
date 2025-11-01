import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/logic/auth/auth_bloc.dart';
import 'package:serv_oeste/src/models/auth/auth_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/auth_validator.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';

class UserFormWidget extends StatefulWidget {
  final AuthForm authForm;
  final AuthValidator validator;
  final GlobalKey<FormState> formKey;
  final bool isUpdate;
  final String submitText;
  final String successMessage;
  final VoidCallback onSubmit;

  const UserFormWidget({
    super.key,
    required this.authForm,
    required this.validator,
    required this.formKey,
    this.isUpdate = false,
    required this.submitText,
    required this.successMessage,
    required this.onSubmit,
  });

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  late AuthForm _authForm;
  late AuthValidator _validator;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _authForm = widget.authForm;
    _validator = widget.validator;
    _formKey = widget.formKey;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            validator:
                _validator.byField(_authForm, ErrorCodeKey.username.name),
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
            validator:
                _validator.byField(_authForm, ErrorCodeKey.password.name),
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
            validator: _validator.byField(_authForm, ErrorCodeKey.role.name),
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
              } else if (state
                  is AuthRegisterSuccessState /*|| state is AuthUpdateSuccessState*/) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.successMessage),
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
              child: Text(
                widget.submitText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
