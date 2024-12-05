import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/card_client.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({super.key});

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  late final ClienteBloc _clienteBloc;
  late final TextEditingController _nomeController,
      _telefoneController,
      _enderecoController;
  late final List<int> _selectedItems;
  bool isSelected = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _clienteBloc = context.read<ClienteBloc>();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    _selectedItems = [];
  }

  void _onSearchFieldChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      Duration(milliseconds: 150),
      () => _clienteBloc.add(
        ClienteSearchEvent(
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          endereco: _enderecoController.text,
        ),
      ),
    );
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
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }

      isSelected = _selectedItems.isNotEmpty;
    });
  }

  // Widget _buildEditableSection(int id) => Row(
  //   mainAxisAlignment: MainAxisAlignment.end,
  //   crossAxisAlignment: CrossAxisAlignment.center,
  //   mainAxisSize: MainAxisSize.min,
  //   children: [
  //     IconButton(
  //       onPressed: () {
  //         setState(() {
  //           isSelected = false;
  //           _selectedItems.clear();
  //         });
  //
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => UpdateCliente(id: id))).then(
  //             (value) => value ?? _clienteBloc.add(ClienteSearchEvent()));
  //       },
  //       icon: const Icon(Icons.edit, color: Colors.white),
  //       style: const ButtonStyle(
  //           backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
  //     ),
  //     const SizedBox(
  //       width: 16,
  //     ),
  //     IconButton(
  //       onPressed: () {
  //         setState(() {
  //           isSelected = false;
  //           _selectedItems.clear();
  //         });
  //       },
  //       icon: const Icon(Icons.content_paste, color: Colors.white),
  //       style: const ButtonStyle(
  //           backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
  //     )
  //   ],
  // );

  Widget _buildSearchInputs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final isMediumScreen = screenWidth >= 500 && screenWidth < 1000;
    final maxContainerWidth = 1200.0;

    Widget buildSearchField(
            {required String hint,
            TextEditingController? controller,
            TextInputType? keyboardType}) =>
        CustomSearchTextField(
          hint: hint,
          leftPadding: 0,
          rightPadding: 8,
          controller: controller,
          keyboardType: keyboardType,
          onChangedAction: (value) => _onSearchFieldChanged(),
        );

    Widget buildLargeScreenLayout() => Row(
          children: [
            Expanded(
              flex: 2,
              child: buildSearchField(
                hint: "Procure por Clientes...",
                controller: _nomeController,
              ),
            ),
            Expanded(
              flex: 2,
              child: buildSearchField(
                hint: 'Endereço...',
                controller: _enderecoController,
              ),
            ),
            Expanded(
              flex: 1,
              child: buildSearchField(
                hint: 'Telefone...',
                keyboardType: TextInputType.phone,
                controller: _telefoneController,
              ),
            ),
          ],
        );

    Widget buildMediumScreenLayout() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: buildSearchField(
                hint: "Procure por Clientes...",
                controller: _nomeController,
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: buildSearchField(
                    hint: 'Telefone...',
                    keyboardType: TextInputType.phone,
                    controller: _telefoneController,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: buildSearchField(
                    hint: 'Endereço...',
                    controller: _enderecoController,
                  ),
                ),
              ],
            ),
          ],
        );

    Widget buildSmallScreenLayout() => Column(
          children: [
            buildSearchField(
              hint: "Procure por Clientes...",
              controller: _nomeController,
            ),
            buildSearchField(
              hint: 'Telefone...',
              keyboardType: TextInputType.phone,
              controller: _telefoneController,
            ),
            buildSearchField(
              hint: 'Endereço...',
              controller: _enderecoController,
            ),
          ],
        );

    return Container(
      width: isLargeScreen ? maxContainerWidth : double.infinity,
      padding: const EdgeInsets.all(5),
      child: (isLargeScreen)
          ? buildLargeScreenLayout()
          : (isMediumScreen)
              ? buildMediumScreenLayout()
              : buildSmallScreenLayout(),
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
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocBuilder<ClienteBloc, ClienteState>(
              bloc: _clienteBloc,
              builder: (context, state) {
                if (state is ClienteInitialState || state is ClienteLoadingState) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                else if (state is ClienteSearchSuccessState) {
                  return SingleChildScrollView(
                    child: GridListView(
                      aspectRatio: 1.75,
                      dataList: state.clientes,
                      buildCard: (cliente) => CardClient(
                        name: (cliente as Cliente).nome!,
                        onTap: () => _selectItems((cliente).id!),
                        phoneNumber: cliente.telefoneFixo!,
                        cellphone: cliente.telefoneCelular!,
                        city: cliente.municipio!,
                        street: cliente.endereco!,
                        isSelected: _selectedItems.contains(cliente.id),
                      ),
                    ),
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.not_interested, size: 30),
                    const SizedBox(height: 16),
                    const Text("Aconteceu um erro!!"),
                  ],
                );
              },
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
    super.dispose();
  }
}
//TODO - Tentar passar toda a lógica de selecionamento de cards para um Bloc/Cubit