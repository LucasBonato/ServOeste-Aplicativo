import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/card_client.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({super.key});

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  final ClienteBloc _clienteBloc = ClienteBloc();
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

  void _disableClientes() {
    final List<int> selectedItemsCopy = List<int>.from(_selectedItems);
    _clienteBloc.add(ClienteDeleteListEvent(selectedList: selectedItemsCopy));
    setState(() {
      _selectedItems.clear();
      isSelected = false;
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

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateCliente(id: id))).then(
              (value) => value ?? _clienteBloc.add(ClienteSearchEvent()));
        },
        icon: const Icon(Icons.edit, color: Colors.white),
        style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
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
        style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
      )
    ],
  );

  Widget _buildClienteCard(dynamic data) {
    // final isCardSelected = _selectedItems.contains(data['id']);
    return GestureDetector(
      onTap: () => _selectItems(data['id']),
      // child: CardClient(
      //   name: data['name'],
      //   phoneNumber: data['phoneNumber'],
      //   city: data['city'],
      //   street: data['street'],
      //   isSelected: true,
      // ),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildSearchInputs(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final isMediumScreen = screenWidth >= 500 && screenWidth < 1000;
    final maxContainerWidth = 1200.0;

    return Center(
      child: Container(
        width: isLargeScreen ? maxContainerWidth : double.infinity,
        padding: const EdgeInsets.all(5),
        child: isLargeScreen
            ? Row(
          children: [
            Expanded(
              flex: 2,
              child: SearchTextField(
                hint: "Procure por Clientes...",
                controller: _nomeController,
                onChangedAction: (String nome) {
                  _clienteBloc.add(
                    ClienteSearchEvent(
                      nome: nome,
                      telefone: _telefoneController.text,
                      endereco: _enderecoController.text,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: SearchTextField(
                hint: 'Telefone...',
                keyboardType: TextInputType.phone,
                controller: _telefoneController,
                leftPadding: 0,
                onChangedAction: (String telefone) {
                  _clienteBloc.add(
                    ClienteSearchEvent(
                      nome: _nomeController.text,
                      telefone: telefone,
                      endereco: _enderecoController.text,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: SearchTextField(
                hint: 'Endereço...',
                controller: _enderecoController,
                leftPadding: 0,
                onChangedAction: (String endereco) {
                  _clienteBloc.add(
                    ClienteSearchEvent(
                      nome: _nomeController.text,
                      telefone: _telefoneController.text,
                      endereco: endereco,
                    ),
                  );
                },
              ),
            ),
          ],
        )
            : isMediumScreen
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: SearchTextField(
                hint: "Procure por Clientes...",
                controller: _nomeController,
                onChangedAction: (String nome) {
                  _clienteBloc.add(
                    ClienteSearchEvent(
                      nome: nome,
                      telefone: _telefoneController.text,
                      endereco: _enderecoController.text,
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: SearchTextField(
                      hint: 'Telefone...',
                      keyboardType: TextInputType.phone,
                      controller: _telefoneController,
                      onChangedAction: (String telefone) {
                        _clienteBloc.add(
                          ClienteSearchEvent(
                            nome: _nomeController.text,
                            telefone: telefone,
                            endereco: _enderecoController.text,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SearchTextField(
                    hint: 'Endereço...',
                    controller: _enderecoController,
                    onChangedAction: (String endereco) {
                      _clienteBloc.add(
                        ClienteSearchEvent(
                          nome: _nomeController.text,
                          telefone: _telefoneController.text,
                          endereco: endereco,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: SearchTextField(
                hint: "Procure por Clientes...",
                controller: _nomeController,
                onChangedAction: (String nome) {
                  _clienteBloc.add(
                    ClienteSearchEvent(
                      nome: nome,
                      telefone: _telefoneController.text,
                      endereco: _enderecoController.text,
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: SearchTextField(
                hint: 'Telefone...',
                keyboardType: TextInputType.phone,
                controller: _telefoneController,
                onChangedAction: (String telefone) {
                  _clienteBloc.add(
                    ClienteSearchEvent(
                      nome: _nomeController.text,
                      telefone: telefone,
                      endereco: _enderecoController.text,
                    ),
                  );
                },
              ),
            ),
            SearchTextField(
              hint: 'Endereço...',
              controller: _enderecoController,
              onChangedAction: (String endereco) {
                _clienteBloc.add(
                  ClienteSearchEvent(
                    nome: _nomeController.text,
                    telefone: _telefoneController.text,
                    endereco: endereco,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: (!isSelected)
          ? BuildWidgets.buildFabAdd(
              context,
              "/createCliente",
              () => _clienteBloc.add(ClienteSearchEvent()),
              tooltip: 'Adicionar um cliente',
            )
          : BuildWidgets.buildFabRemove(
              context,
              _disableClientes,
              tooltip: 'Excluir clientes selecionados',
            ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildSearchInputs(context),
                Flexible(
                  flex: 1,
                  child: BlocBuilder<ClienteBloc, ClienteState>(
                    bloc: _clienteBloc,
                    builder: (context, state) {
                      if (state is ClienteInitialState ||
                          state is ClienteLoadingState) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      } else if (state is ClienteSearchSuccessState) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridListView(
                            dataList: state.clientes,
                            buildCard: _buildClienteCard,
                          ),
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.not_interested, size: 30),
                            const SizedBox(height: 16),
                            const Text("Aconteceu um erro!!"),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}