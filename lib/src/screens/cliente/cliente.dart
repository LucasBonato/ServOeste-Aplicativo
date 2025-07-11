import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/screen/cards/card_client.dart';
import 'package:serv_oeste/src/components/layout/fab_add.dart';
import 'package:serv_oeste/src/components/layout/fab_remove.dart';
import 'package:serv_oeste/src/components/screen/grid_view.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';
import 'package:serv_oeste/src/components/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/shared/routes.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({super.key});

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  late final ListaBloc _listaBloc;
  late final ClienteBloc _clienteBloc;
  late final TextEditingController _nomeController,
      _telefoneController,
      _enderecoController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _clienteBloc = context.read<ClienteBloc>();
    _listaBloc = context.read<ListaBloc>();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    _listaBloc.add(ListaInitialEvent());
    _setFilterValues();
  }

  void _setFilterValues() {
    _nomeController.text = _clienteBloc.nomeMenu ?? "";
    _telefoneController.text = _clienteBloc.telefoneMenu ?? "";
    _enderecoController.text = _clienteBloc.enderecoMenu ?? "";
  }

  void _onSearchFieldChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      Duration(milliseconds: 150),
      () => _clienteBloc.add(
        ClienteSearchMenuEvent(
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
    _listaBloc.add(ListaClearSelectionEvent());
  }

  void _onSelectItemList(int id) {
    _listaBloc.add(ListaToggleItemSelectEvent(id: id));
  }

  bool _isClienteSelected(int id, ListaState stateLista) {
    return (stateLista is ListaSelectState)
        ? stateLista.selectedIds.contains(id)
        : false;
  }

  bool _isSelectionMode(ListaState stateLista) {
    return (stateLista is ListaSelectState)
        ? stateLista.selectedIds.isNotEmpty
        : false;
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
        CustomSearchTextFormField(
          hint: hint,
          leftPadding: 4,
          rightPadding: 4,
          controller: controller,
          keyboardType: keyboardType,
          onChangedAction: (value) => _onSearchFieldChanged(),
          onSuffixAction: (value) {
            setState(() {
              controller?.clear();
            });
            _onSearchFieldChanged();
          },
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
            buildSearchField(
              hint: "Procure por Clientes...",
              controller: _nomeController,
            ),
            SizedBox(height: 5),
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
            SizedBox(height: 5),
            buildSearchField(
              hint: 'Telefone...',
              keyboardType: TextInputType.phone,
              controller: _telefoneController,
            ),
            SizedBox(height: 5),
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
    _clienteBloc.add(ClienteDeleteListEvent(selectedList: selectedIds));
    _listaBloc.add(ListaClearSelectionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: BlocBuilder<ListaBloc, ListaState>(
        builder: (context, state) {
          final bool hasSelection =
              state is ListaSelectState && state.selectedIds.isNotEmpty;

          return (!hasSelection)
              ? FloatingActionButtonAdd(
                  route: Routes.clienteCreate,
                  event: () => _clienteBloc.add(ClienteSearchMenuEvent()),
                  tooltip: "Adicionar um Cliente")
              : FloatingActionButtonRemove(
                  removeMethod: () {
                    _disableClientes(context, state.selectedIds);
                    context.read<ListaBloc>().add(ListaClearSelectionEvent());
                  },
                  tooltip: "Excluir clientes Selecionados",
                );
        },
      ),
      body: BlocListener<ClienteBloc, ClienteState>(
        listener: (context, state) {
          if (state is ClienteErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error.errorMessage),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildSearchInputs(),
            Expanded(
              child: BlocBuilder<ClienteBloc, ClienteState>(
                bloc: _clienteBloc,
                builder: (context, stateCliente) {
                  if (stateCliente is ClienteLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (stateCliente is ClienteSearchSuccessState ||
                      stateCliente is ClienteErrorState) {
                    final List<Cliente>? clientes =
                        (stateCliente is ClienteSearchSuccessState)
                            ? stateCliente.clientes
                            : (stateCliente as ClienteErrorState).clientes;

                    if (stateCliente is ClienteErrorState) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(stateCliente.error.errorMessage),
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          ),
                        );
                      });
                    }

                    if (clientes != null && clientes.isNotEmpty) {
                      return SingleChildScrollView(
                        child: GridListView(
                          aspectRatio: 1.65,
                          dataList: clientes,
                          buildCard: (cliente) =>
                              BlocBuilder<ListaBloc, ListaState>(
                            bloc: _listaBloc,
                            builder: (context, stateLista) {
                              final bool isSelected =
                                  _isClienteSelected(cliente.id, stateLista);
                              final bool isSelectionMode =
                                  _isSelectionMode(stateLista);

                              return CardClient(
                                onDoubleTap: () =>
                                    _onNavigateToUpdateScreen(cliente.id!),
                                onLongPress: () =>
                                    _onSelectItemList(cliente.id!),
                                onTap: () {
                                  if (isSelectionMode) {
                                    _onSelectItemList(cliente.id!);
                                  }
                                },
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
                    } else {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              color: Colors.grey,
                              size: 40.0,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Nenhum cliente encontrado.",
                              style:
                                  TextStyle(fontSize: 18.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
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
