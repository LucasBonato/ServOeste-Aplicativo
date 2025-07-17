import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/layout/fab_add.dart';
import 'package:serv_oeste/src/components/layout/fab_remove.dart';
import 'package:serv_oeste/src/components/layout/responsive_search_inputs.dart';
import 'package:serv_oeste/src/components/screen/cards/card_client.dart';
import 'package:serv_oeste/src/components/screen/entity_not_found.dart';
import 'package:serv_oeste/src/components/screen/error_component.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/base_list_screen.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';
import 'package:serv_oeste/src/shared/routes.dart';

class ClienteScreen extends BaseListScreen<Cliente> {
  const ClienteScreen({super.key});

  @override
  BaseListScreenState<Cliente> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends BaseListScreenState<Cliente> {
  late final ClienteBloc _clienteBloc;
  late final TextEditingController _nomeController, _telefoneController, _enderecoController;
  final Debouncer debouncer = Debouncer();

  void _setFilterValues() {
    _nomeController.text = _clienteBloc.nomeMenu ?? "";
    _telefoneController.text = _clienteBloc.telefoneMenu ?? "";
    _enderecoController.text = _clienteBloc.enderecoMenu ?? "";
  }

  Widget _buildSearchInputs() {
    return ResponsiveSearchInputs(
      onChanged: onSearchFieldChanged,
      fields: [
        TextInputField(
          hint: "Procure por Clientes...",
          controller: _nomeController,
          keyboardType: TextInputType.text
        ),
        TextInputField(
          hint: "Endereço...",
          controller: _enderecoController,
          keyboardType: TextInputType.text
        ),
        TextInputField(
          hint: "Telefone...",
          controller: _telefoneController,
          keyboardType: TextInputType.phone
        ),
      ],
    );
  }

  @override
  Widget getUpdateScreen(int id) => UpdateCliente(id: id);

  @override
  Widget buildDefaultFloatingActionButton() {
    return FloatingActionButtonAdd(
      route: Routes.clienteCreate,
      event: () => _clienteBloc.add(ClienteSearchMenuEvent()),
      tooltip: "Adicionar um Cliente"
    );
  }

  @override
  Widget buildSelectionFloatingActionButton(List<int> selectedIds) {
    return FloatingActionButtonRemove(
      removeMethod: () => disableSelectedItems(context, selectedIds),
      tooltip: "Excluir clientes Selecionados",
    );
  }

  @override
  Widget buildItemCard(Cliente cliente, bool isSelected, bool isSelectMode) {
    return CardClient(
      onDoubleTap: () => onNavigateToUpdateScreen(cliente.id!),
      onLongPress: () => onSelectItemList(cliente.id!),
      onTap: () {
        if (isSelectMode) {
          onSelectItemList(cliente.id!);
        }
      },
      name: cliente.nome!,
      phoneNumber: cliente.telefoneFixo!,
      cellphone: cliente.telefoneCelular!,
      city: cliente.municipio!,
      street: cliente.endereco!,
      isSelected: isSelected,
    );
  }

  @override
  void onSearchFieldChanged() {
    debouncer.execute(
      () => _clienteBloc.add(
        ClienteSearchMenuEvent(
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          endereco: _enderecoController.text,
        ),
      )
    );
  }

  @override
  void onDisableItems(List<int> selectedIds) {
    _clienteBloc.add(ClienteDeleteListEvent(selectedList: selectedIds));
  }

  @override
  void initState() {
    super.initState();
    _clienteBloc = context.read<ClienteBloc>();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    _setFilterValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: buildFloatingActionButton(),
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocBuilder<ClienteBloc, ClienteState>(
              builder: (context, stateCliente) {
                if (stateCliente is ClienteInitialState || stateCliente is ClienteLoadingState) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                else if (stateCliente is ClienteSearchSuccessState) {
                  if (stateCliente.clientes.isNotEmpty) {
                    return buildGridOfCards(stateCliente.clientes, 1.65);
                  }
                  return const EntityNotFound(message: "Nenhum cliente encontrado.");
                }
                else if (stateCliente is ClienteErrorState) {
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
                return const ErrorComponent();
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