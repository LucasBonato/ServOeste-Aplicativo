import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:serv_oeste/src/components/expandable_fab_items.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';

import '../../components/search_field.dart';
import '../../models/cliente/cliente.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClientePage> {
  late final ClienteBloc _clienteBloc = ClienteBloc();
  late final TextEditingController _nomeController, _telefoneController, _enderecoController;
  late final List<int> _selectedItems;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _clienteBloc.add(ClienteLoadingEvent());
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    _selectedItems = [];
  }

  @override
  void dispose() {
    _selectedItems.clear();
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _clienteBloc.close();
    super.dispose();
  }

  void _disableClientes() async {
    _clienteBloc.add(ClienteDeleteListEvent(selectedList: _selectedItems));
    setState(() {
      _selectedItems.clear();
    });
  }

  void _selectItems(int id) {
    if (_selectedItems.contains(id)) {
      setState(() {
        _selectedItems.remove(id);
      });
      return;
    }
    _selectedItems.add(id);
    setState(() {
      if (!isSelected) isSelected = true;
    });
  }

  ExpandableFabItems _buildFab() => const ExpandableFabItems(
    firstHeroTag: "cliente",
    secondHeroTag: "servico",
    firstRouterName: "/createCliente",
    secondRouterName: "/createServico",
    firstText: "Cliente",
    secondText: "Serviço"
  );

  Widget _buildEditableSection(int id) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: () {
          setState(() {
            isSelected = false;
            _selectedItems.clear();
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateCliente(id: id))
          );
        },
        icon: const Icon(Icons.edit, color: Colors.white),
        style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
      ),
      const SizedBox(
        width: 16,
      ),
      IconButton(
        onPressed: () {
          setState(() {
            isSelected = false;
            _selectedItems.clear();
          });
        },
        icon: const Icon(Icons.content_paste, color: Colors.white),
        style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: (!isSelected) ? _buildFab() : BuildWidgets.buildFabRemove(context, _disableClientes),
      body: Column(
        children: [
          SearchTextField(
            hint: "Procure por Clientes...",
            controller: _nomeController,
            onChangedAction: (String nome) => _clienteBloc.add(ClienteSearchEvent(
              nome: nome,
              telefone: _telefoneController.text,
              endereco: _enderecoController.text
            ))
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SearchTextField(
                  hint: "Telefone...",
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  rightPadding: 0,
                  onChangedAction: (String telefone) => _clienteBloc.add(ClienteSearchEvent(
                    nome: _nomeController.text,
                    telefone: telefone,
                    endereco: _enderecoController.text
                  ))
                ),
              ),
              Expanded(
                flex: 5,
                child: SearchTextField(
                  hint: "Endereço...",
                  controller: _enderecoController,
                  leftPadding: 8,
                  onChangedAction: (String endereco) => _clienteBloc.add(ClienteSearchEvent(
                    nome: _nomeController.text,
                    telefone: _telefoneController.text,
                    endereco: endereco
                  ))
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color.fromRGBO(21, 72, 169, 1)
              ),
              child: const SizedBox(
                width: double.infinity,
                height: 50,
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text("Id", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text("Nome", textAlign: TextAlign.start, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("Município", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: BlocBuilder<ClienteBloc, ClienteState>(
              bloc: _clienteBloc,
              builder: (context, state) {
                return switch(state) {
                  ClienteInitialState() ||
                  ClienteLoadingState() => const Center(child: CircularProgressIndicator.adaptive()),

                  ClienteSuccessState() => SuperListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    scrollDirection: Axis.vertical,
                    itemCount: state.clientes.length,
                    itemBuilder: (context, index) {
                      final Cliente cliente = state.clientes[index];
                      final int id = cliente.id!;
                      final bool editable = (isSelected && _selectedItems.length == 1 && _selectedItems.contains(id));
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: ListTile(
                          leading: Text(
                            "$id",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          title: Text(
                            cliente.nome!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold
                            )
                          ),
                          subtitle: Text(Constants.transformTelefone(cliente: cliente)),
                          trailing: (editable) ? _buildEditableSection(id) : Text(cliente.municipio?? "UF"),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          tileColor: const Color.fromRGBO(239, 239, 239, 100),
                          selectedTileColor: Colors.blue.withOpacity(.5),
                          selected: _selectedItems.contains(id),
                          onLongPress: () => _selectItems(id),
                          onTap: () {
                            if (_selectedItems.isNotEmpty) {
                              _selectItems(id);
                            }
                            if (_selectedItems.isEmpty) {
                              isSelected = false;
                            }
                          },
                        ),
                      );
                    },
                  ),

                  _ => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.not_interested, size: 30),
                      const SizedBox(height: 16),
                      Text("Aconteceu um erro!!")
                    ],
                  ),
                };
              },
            )
          )
        ]
      )
    );
  }
}