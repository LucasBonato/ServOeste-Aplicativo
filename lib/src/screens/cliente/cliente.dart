import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/card_client.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';
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
          leftPadding: 8,
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
      floatingActionButton: BlocBuilder<ClienteBloc, ClienteState>(
        builder: (context, state) {
          final bool hasSelection =
              state is ClienteListState && state.selectedIds.isNotEmpty;

          return !hasSelection
              ? BuildWidgets.buildFabAdd(
                  context,
                  "/createCliente",
                  () {
                    _clienteBloc.add(ClienteSearchEvent());
                  },
                  tooltip: 'Adicionar um cliente',
                )
              : BuildWidgets.buildFabRemove(
                  context,
                  () {
                    _clienteBloc.add(ClienteDeleteListEvent(
                        selectedList: state.selectedIds));
                  },
                  tooltip: 'Excluir clientes selecionados',
                );
        },
      ),
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocBuilder<ClienteBloc, ClienteState>(
              bloc: _clienteBloc,
              builder: (context, state) {
                if (state is ClienteLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else if (state is ClienteListState) {
                  return SingleChildScrollView(
                    child: GridListView(
                      aspectRatio: 1.65,
                      dataList: state.clientes,
                      buildCard: (cliente) => CardClient(
                        onDoubleTap: () {
                          int clienteId = cliente.id!;
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => UpdateCliente(id: clienteId),
                            ),
                          );
                          _clienteBloc
                              .add(ClienteToggleItemSelectEvent(id: clienteId));
                        },
                        onLongPress: () => _clienteBloc
                            .add(ClienteToggleItemSelectEvent(id: cliente.id!)),
                        name: cliente.nome!,
                        phoneNumber: cliente.telefoneFixo!,
                        cellphone: cliente.telefoneCelular!,
                        city: cliente.municipio!,
                        street: cliente.endereco!,
                        isSelected: state.selectedIds.contains(cliente.id),
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