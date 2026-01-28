import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/features/user/presentation/bloc/user_bloc.dart';
import 'package:serv_oeste/src/models/user/user_form.dart';
import 'package:serv_oeste/features/user/presentation/widgets/user_form_widget.dart';
import 'package:serv_oeste/src/utils/extensions/role_extensions.dart';

class UpdateUserScreen extends StatefulWidget {
  final int id;
  final String username;
  final String role;

  const UpdateUserScreen({
    super.key,
    required this.id,
    required this.username,
    required this.role,
  });

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late final UserBloc bloc;
  final UserForm form = UserForm();

  void _fillForm() {
    form.setId(widget.id);
    form.setUsername(widget.username);
    form.setRole(widget.role.toDisplayRole());
  }

  @override
  void initState() {
    super.initState();
    bloc = context.read<UserBloc>();
    _fillForm();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) => current is UserUpdatedState,
      listener: (context, state) {
        if (state is UserUpdatedState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            }
          });
        }
      },
      child: UserFormWidget(
        bloc: bloc,
        title: "Editar Usuário",
        submitText: "Atualizar Usuário",
        isSkeleton: false,
        isUpdate: true,
        userForm: form,
        successMessage: "Usuário atualizado com sucesso!",
        onSubmit: () {
          final String backendRole = form.role.value.toBackendRole();

          bloc.add(UpdateUserEvent(
            id: form.id!,
            username: form.username.value,
            password: form.password.value,
            role: backendRole,
          ));
        },
      ),
    );
  }
}
