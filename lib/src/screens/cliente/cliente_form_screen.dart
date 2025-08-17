import 'package:flutter/material.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/screens/cliente/cliente_form.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ClienteFormScreen extends StatelessWidget {
  final String title;
  final String submitText;
  final ClienteBloc bloc;
  final ClienteForm clienteForm;
  final void Function() onSubmit;
  final TextEditingController? nomeController;
  final bool isUpdate;
  final bool isSkeleton;

  const ClienteFormScreen({
    super.key,
    required this.title,
    required this.submitText,
    required this.bloc,
    required this.clienteForm,
    required this.onSubmit,
    this.nomeController,
    this.isUpdate = false,
    this.isSkeleton = false
  });

  @override
  Widget build(BuildContext context) {
    return BaseFormScreen(
      title: title,
      shouldActivateEvent: isUpdate,
      child: Skeletonizer(
        enabled: isSkeleton,
        child: ClienteFormWidget(
          clienteForm: clienteForm,
          bloc: bloc,
          isUpdate: isUpdate,
          submitText: submitText,
          onSubmit: onSubmit,
          nomeController: nomeController,
        ),
      ),
    );
  }
}
