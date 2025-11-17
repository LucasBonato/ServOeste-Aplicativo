import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/screens/cliente/cliente_form_screen.dart';

class UpdateCliente extends StatefulWidget {
  final int id;

  const UpdateCliente({
    super.key,
    required this.id,
  });

  @override
  State<UpdateCliente> createState() => _UpdateClienteState();
}

class _UpdateClienteState extends State<UpdateCliente> {
  late final ClienteBloc bloc;
  final ClienteForm form = ClienteForm();
  final TextEditingController nomeController = TextEditingController();

  void _fillForm(Cliente cliente, TextEditingController nomeController) {
    form.setId(widget.id);
    form.setNome(cliente.nome ?? "");
    nomeController.text = form.nome.value;

    form.setTelefoneFixo(cliente.telefoneFixo ?? "");
    form.setTelefoneCelular(cliente.telefoneCelular ?? "");

    form.setMunicipio(cliente.municipio ?? "");
    form.setBairro(cliente.bairro ?? "");

    final List<String> addressParts = (cliente.endereco ?? "").split(",");

    String rua = addressParts[0].trim();
    String numero = addressParts.length > 1 ? addressParts[1].trim() : '';
    String complemento = addressParts.length > 2 ? addressParts.sublist(2).join(',').trim() : '';

    form.setRua(rua);
    form.setNumero(numero);
    form.setComplemento(complemento);
  }

  @override
  void initState() {
    super.initState();
    bloc = context.read<ClienteBloc>();
    bloc.add(ClienteSearchOneEvent(id: widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClienteBloc, ClienteState>(
      listenWhen: (previous, current) => current is ClienteUpdateSuccessState || current is ClienteSearchOneSuccessState,
      listener: (context, state) {
        if (state is ClienteUpdateSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            }
          });
        } else if (state is ClienteSearchOneSuccessState) {
          _fillForm(state.cliente, nomeController);
        }
      },
      child: BlocBuilder<ClienteBloc, ClienteState>(
        bloc: bloc,
        buildWhen: (previous, current) => current is ClienteSearchOneSuccessState || current is ClienteSearchOneLoadingState,
        builder: (context, state) {
          return ClienteFormScreen(
            isSkeleton: state is ClienteSearchOneLoadingState,
            title: "Consultar/Atualizar Cliente",
            submitText: "Atualizar Cliente",
            bloc: bloc,
            clienteForm: form,
            nomeController: nomeController,
            isUpdate: true,
            successMessage: 'Cliente atualizado com sucesso! (Caso ele não esteja atualizado, recarregue a página)',
            onSubmit: () {
              final List<String> nomesSplit = form.nome.value.split(" ");
              final String nome = nomesSplit.first;
              final String sobrenome = nomesSplit.sublist(1).join(" ").trim();

              form.setNome(nome);

              bloc.add(ClienteUpdateEvent(
                cliente: Cliente.fromForm(form),
                sobrenome: sobrenome,
              ));

              form.setNome("$nome $sobrenome");
            },
          );
        },
      ),
    );
  }
}
