import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/screens/cliente/cliente_form_screen.dart';

class CreateCliente extends StatelessWidget {
  const CreateCliente({super.key});

  @override
  Widget build(BuildContext context) {
    final ClienteBloc bloc = context.read<ClienteBloc>();
    final ClienteForm form = ClienteForm();

    return ClienteFormScreen(
      title: "Adicionar Cliente",
      submitText: "Adicionar Cliente",
      bloc: bloc,
      clienteForm: form,
      onSubmit: () {
        final List<String> nomesSplit = form.nome.value.split(" ");
        final String nome = nomesSplit.first;
        final String sobrenome = nomesSplit.sublist(1).join(" ").trim();

        form.setNome(nome);

        bloc.add(ClienteRegisterEvent(
          cliente: Cliente.fromForm(form),
          sobrenome: sobrenome,
        ));

        form.setNome("$nome $sobrenome");
      },
    );
  }
}
