import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/src/components/screen/filtered_clients_table.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';

class ClientSelectionModal extends StatefulWidget {
  final TextEditingController nomeController;
  final TextEditingController enderecoController;
  final Function(String nome) onClientSelected;

  const ClientSelectionModal({
    super.key,
    required this.nomeController,
    required this.enderecoController,
    required this.onClientSelected,
  });

  @override
  ClientSelectionModalState createState() => ClientSelectionModalState();
}

class ClientSelectionModalState extends State<ClientSelectionModal> {
  Timer? _debounce;
  List<Map<String, String>> _clientesFiltrados = [];

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ClienteBloc>().add(ClienteSearchEvent(
            nome: widget.nomeController.text,
            endereco: widget.enderecoController.text,
          ));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSearchTextFormField(
            hint: "Nome do Cliente",
            leftPadding: 0,
            rightPadding: 0,
            controller: widget.nomeController,
            onChangedAction: (value) => _onSearchChanged(),
          ),
          const SizedBox(height: 12),
          CustomSearchTextFormField(
            hint: "Endereço",
            leftPadding: 0,
            rightPadding: 0,
            controller: widget.enderecoController,
            onChangedAction: (value) => _onSearchChanged(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 550,
            height: 250,
            child: BlocBuilder<ClienteBloc, ClienteState>(
              builder: (context, state) {
                if (state is ClienteSearchOneSuccessState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Pesquise um cliente",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ClienteSearchSuccessState) {
                  _clientesFiltrados = state.clientes
                      .map((cliente) => {
                            'id': cliente.id.toString(),
                            'nome': cliente.nome ?? '',
                            'endereco': cliente.endereco ?? '',
                          })
                      .toList();

                  if (_clientesFiltrados.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Nenhum cliente encontrado",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return FilteredClientsTable(
                    clientesFiltrados: _clientesFiltrados,
                    onClientSelected: (id) {
                      widget.onClientSelected(id);
                      widget.nomeController.text = '';
                      widget.enderecoController.text = '';
                      Navigator.pop(context);
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
