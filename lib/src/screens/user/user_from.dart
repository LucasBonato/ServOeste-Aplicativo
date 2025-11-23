import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/logic/user/user_bloc.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/user/user_form.dart';
import 'package:serv_oeste/src/models/validators/user_validator.dart';
import 'package:serv_oeste/src/screens/base_entity_form.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserFormPage extends StatelessWidget {
  final String title;
  final bool isUpdate;
  final bool isSkeleton;
  final UserBloc bloc;
  final UserForm userForm;
  final String successMessage;
  final String submitText;
  final void Function() onSubmit;

  const UserFormPage({
    super.key,
    required this.title,
    required this.bloc,
    required this.userForm,
    required this.successMessage,
    required this.submitText,
    required this.onSubmit,
    this.isUpdate = false,
    this.isSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final UserValidator validator = UserValidator();

    return BaseFormScreen(
      title: title,
      shouldActivateEvent: isUpdate,
      child: Skeletonizer(
        enabled: isSkeleton,
        child: BaseEntityForm<UserBloc, UserState>(
          bloc: bloc,
          formKey: formKey,
          getSuccessMessage: (state) => successMessage,
          submitText: submitText,
          isLoading: (state) => state is UserLoadingState || state is UserOperationLoadingState,
          isSuccess: (state) => isUpdate ? state is UserUpdatedState : state is UserCreatedState,
          isError: (state) => state is UserErrorState,
          space: 20,
          onError: (state) {
            if (state is UserErrorState) {
              validator.applyBackendError(state.error);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                formKey.currentState?.validate();
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error.detail),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          onSubmit: () async {
            validator.cleanExternalErrors();
            formKey.currentState!.validate();
            final result = validator.validate(userForm);
            if (!result.isValid) return;

            onSubmit();
          },
          buildFields: () => [
            TextFormInputField(
              label: "Nome do Usuário*",
              hint: "Digite o nome do usuário",
              maxLength: 255,
              valueNotifier: userForm.username,
              validator: validator.byField(userForm, ErrorCodeKey.username.name),
              onChanged: userForm.setUsername,
              keyboardType: TextInputType.name,
            ),
            TextFormInputField(
              label: "Senha*",
              hint: "Digite a senha do usuário",
              maxLength: 24,
              valueNotifier: userForm.password,
              validator: validator.byField(userForm, ErrorCodeKey.password.name),
              onChanged: userForm.setPassword,
              keyboardType: TextInputType.visiblePassword,
            ),
            DropdownInputField(
              hint: "Cargo*",
              valueNotifier: userForm.role,
              onChanged: userForm.setRole,
              validator: validator.byField(userForm, ErrorCodeKey.role.name),
              dropdownValues: Constants.roleUserDisplayList,
            ),
          ],
        ),
      ),
    );
  }
}
