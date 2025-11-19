import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/models/user/user_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/user_validator.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';

class UserFormWidget extends StatefulWidget {
  final UserForm userForm;
  final UserValidator validator;
  final GlobalKey<FormState> formKey;
  final bool isUpdate;
  final String submitText;
  final String successMessage;
  final VoidCallback onSubmit;

  const UserFormWidget({
    super.key,
    required this.userForm,
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
  late UserForm _userForm;
  late UserValidator _validator;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _userForm = widget.userForm;
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
            valueNotifier: _userForm.username,
            validator:
                _validator.byField(_userForm, ErrorCodeKey.username.name),
            onChanged: _userForm.setUsername,
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
            valueNotifier: _userForm.password,
            validator:
                _validator.byField(_userForm, ErrorCodeKey.password.name),
            onChanged: _userForm.setPassword,
          ),
          const SizedBox(height: 20),
          CustomDropdownFormField(
            label: 'Cargo*',
            leftPadding: 0,
            rightPadding: 0,
            valueNotifier: _userForm.role,
            onChanged: _userForm.setRole,
            dropdownValues: Constants.roleUserDisplayList,
            validator: _validator.byField(_userForm, ErrorCodeKey.role.name),
          ),
          const SizedBox(height: 30),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserError) {
                _validator.applyBackendError(state.error);
                _formKey.currentState?.validate();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error.detail),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is UserCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.successMessage),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                final isLoading = state is UserOperationLoading;

                return ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.submitText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
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
