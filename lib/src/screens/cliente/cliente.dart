import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/card_client.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final ClienteBloc _clienteBloc = ClienteBloc();
  late final TextEditingController _nomeController,
      _telefoneController,
      _ruaController,
      _numeroController;
  late final List<int> _selectedItems;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _clienteBloc.add(ClienteLoadingEvent());
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _ruaController = TextEditingController();
    _numeroController = TextEditingController();
    _selectedItems = [];
  }

  void _disableClientes() {
    final List<int> selectedItemsCopy = List<int>.from(_selectedItems);
    _clienteBloc.add(ClienteDeleteListEvent(selectedList: selectedItemsCopy));
    setState(() {
      _selectedItems.clear();
      isSelected = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Clientes selecionados deletados com sucesso!')),
    );
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

  Widget _buildClienteCard(dynamic data) {
    final isCardSelected = _selectedItems.contains(data['id']);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateCliente(id: data['id']),
          ),
        );
      },
      onDoubleTap: () {
        _selectItems(data['id']);
      },
      onLongPress: () {
        _selectItems(data['id']);
      },
      child: CardClient(
        nome: data['nome'],
        telefone: data['telefone'],
        celular: data['celular'],
        cidade: data['cidade'],
        rua: data['rua'],
        numero: data['numero'],
        isSelected: isCardSelected,
      ),
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
                            rua: _ruaController.text,
                            numero: _numeroController.text,
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
                            rua: _ruaController.text,
                            numero: _numeroController.text,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SearchTextField(
                      hint: 'Endereço...',
                      leftPadding: 0,
                      controller: _ruaController,
                      onChangedAction: (String endereco) {
                        final splitEndereco = endereco.split(',');
                        final rua = splitEndereco.isNotEmpty
                            ? splitEndereco[0].trim()
                            : '';
                        final numero = splitEndereco.length > 1
                            ? splitEndereco[1].trim()
                            : '';

                        _clienteBloc.add(
                          ClienteSearchEvent(
                            nome: _nomeController.text,
                            telefone: _telefoneController.text,
                            rua: rua,
                            numero: numero,
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
                                rua: _ruaController.text,
                                numero: _numeroController.text,
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
                                      rua: _ruaController.text,
                                      numero: _numeroController.text,
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
                              leftPadding: 0,
                              controller: _ruaController,
                              onChangedAction: (String endereco) {
                                final splitEndereco = endereco.split(',');
                                final rua = splitEndereco.isNotEmpty
                                    ? splitEndereco[0].trim()
                                    : '';
                                final numero = splitEndereco.length > 1
                                    ? splitEndereco[1].trim()
                                    : '';

                                _clienteBloc.add(
                                  ClienteSearchEvent(
                                    nome: _nomeController.text,
                                    telefone: _telefoneController.text,
                                    rua: rua,
                                    numero: numero,
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
                                rua: _ruaController.text,
                                numero: _numeroController.text,
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
                                rua: _ruaController.text,
                                numero: _numeroController.text,
                              ),
                            );
                          },
                        ),
                      ),
                      SearchTextField(
                        hint: 'Endereço...',
                        leftPadding: 0,
                        controller: _ruaController,
                        onChangedAction: (String endereco) {
                          final splitEndereco = endereco.split(',');
                          final rua = splitEndereco.isNotEmpty
                              ? splitEndereco[0].trim()
                              : '';
                          final numero = splitEndereco.length > 1
                              ? splitEndereco[1].trim()
                              : '';

                          _clienteBloc.add(
                            ClienteSearchEvent(
                              nome: _nomeController.text,
                              telefone: _telefoneController.text,
                              rua: rua,
                              numero: numero,
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
    return BlocBuilder<ClienteBloc, ClienteState>(
      bloc: _clienteBloc,
      builder: (context, state) {
        Widget content;

        if (state is ClienteLoadingState) {
          content = Column(
            children: [
              _buildSearchInputs(context),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        } else if (state is ClienteSearchSuccessState) {
          content = ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              _buildSearchInputs(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridListView(
                  dataList: state.clientes,
                  buildCard: (data) => _buildClienteCard(data),
                ),
              ),
            ],
          );
        } else {
          content = Column(
            children: [
              _buildSearchInputs(context),
              const Expanded(
                child: Center(child: Text('Erro ao carregar dados.')),
              ),
            ],
          );
        }

        final floatingActionButton = (!isSelected)
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
              );

        return Scaffold(
          floatingActionButton: floatingActionButton,
          body: content,
        );
      },
    );
  }

  @override
  void dispose() {
    _selectedItems.clear();
    _nomeController.dispose();
    _telefoneController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _clienteBloc.close();
    super.dispose();
  }
}
