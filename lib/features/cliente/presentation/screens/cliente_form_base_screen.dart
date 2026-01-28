import 'package:flutter/material.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_form.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/cliente/presentation/widgets/cliente_form_widget.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ClienteFormScreen extends StatelessWidget {
  final String title;
  final String submitText;
  final String successMessage;
  final ClienteBloc bloc;
  final ClienteForm form;
  final void Function() onSubmit;
  final TextEditingController? nomeController;
  final bool isUpdate;
  final bool isSkeleton;

  const ClienteFormScreen({
    super.key,
    required this.form,
    required this.bloc,
    required this.title,
    required this.onSubmit,
    required this.submitText,
    required this.successMessage,
    this.nomeController,
    this.isUpdate = false,
    this.isSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseFormScreen(
      title: title,
      shouldActivateEvent: isUpdate,
      child: Skeletonizer(
        child: ClienteFormWidget(
          bloc: bloc,
          clienteForm: form,
          isUpdate: isUpdate,
          onSubmit: onSubmit,
          isCreateCliente: true,
          submitText: submitText,
          nomeController: nomeController,
          getSuccessMessage: (state) => successMessage,
        ),
      ),
    );
  }
}
