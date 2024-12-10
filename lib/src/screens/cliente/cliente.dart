import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/card_client.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/logic/list/list_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
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
  late final ListBloc _listBloc;
  late final ClienteBloc _clienteBloc;
  late final TextEditingController _nomeController,
      _telefoneController,
      _enderecoController;
  bool isSelected = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _clienteBloc = context.read<ClienteBloc>();
    _listBloc = context.read<ListBloc>();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    _listBloc.add(ListInitialEvent());
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

  void _onNavigateToUpdateScreen(int id) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => UpdateCliente(id: id),
      ),
    );
    _listBloc.add(ListClearSelectionEvent());
  }

  void _onLongPressSelectItemList(int id) {
    _listBloc.add(ListToggleItemSelectEvent(id: id));
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

  void _disableClientes(BuildContext context, List<int> selectedIds) {
    _clienteBloc.add(TecnicoDisableListEvent(selectedList: selectedIds));
    _listBloc.add(ListClearSelectionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: BlocBuilder<ListBloc, ListState>(
        builder: (context, state) {
          final bool hasSelection =
              state is ListSelectState && state.selectedIds.isNotEmpty;

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
                    _disableClientes(context, state.selectedIds);

                    context.read<ListBloc>().add(ListClearSelectionEvent());
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
              builder: (context, stateCliente) {
                if (stateCliente is ClienteLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else if (stateCliente is ClienteSearchSuccessState) {
                  return SingleChildScrollView(
                    child: GridListView(
                      aspectRatio: 1.65,
                      dataList: stateCliente.clientes,
                      buildCard: (cliente) => BlocBuilder<ListBloc, ListState>(
                        bloc: _listBloc,
                        builder: (context, stateList) {
                          bool isSelected = false;

                          if (stateList is ListSelectState) {
                            isSelected = stateList.selectedIds
                                .contains((cliente as Cliente).id);
                          }

                          return CardClient(
                            onDoubleTap: () =>
                                _onNavigateToUpdateScreen(cliente.id!),
                            onLongPress: () =>
                                _onLongPressSelectItemList(cliente.id!),
                            name: (cliente as Cliente).nome!,
                            phoneNumber: cliente.telefoneFixo!,
                            cellphone: cliente.telefoneCelular!,
                            city: cliente.municipio!,
                            street: cliente.endereco!,
                            isSelected: isSelected,
                          );
                        },
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
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }
}
