import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_form.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_form_base_screen.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';

class ClienteCreateScreen extends StatelessWidget {
  const ClienteCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClienteBloc bloc = context.read<ClienteBloc>();
    final ClienteForm form = ClienteForm();

    return ClienteFormScreen(
      title: "Adicionar Cliente",
      submitText: "Adicionar Cliente",
      bloc: bloc,
      form: form,
      successMessage: "Cliente registrado com sucesso! (Caso ele não esteja aparecendo, recarregue a página)",
      onSubmit: () {
        final List<String> nomesSplit = form.nome.value.split(" ");
        final String nome = nomesSplit.first;
        final String sobrenome = nomesSplit.sublist(1).join(" ").trim();

        form.setNome(nome);

        bloc.add(
          ClienteRegisterEvent(
            cliente: Cliente.fromForm(form),
            sobrenome: sobrenome,
          ),
        );

        form.setNome("$nome $sobrenome");
      },
    );
  }
}
