import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/core/routing/routes.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/cliente/presentation/screens/cliente_update_screen.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_input_field.dart';
import 'package:serv_oeste/shared/widgets/layout/fab_add.dart';
import 'package:serv_oeste/shared/widgets/layout/fab_remove.dart';
import 'package:serv_oeste/shared/widgets/layout/responsive_search_inputs.dart';
import 'package:serv_oeste/features/cliente/presentation/widgets/cliente_card.dart';
import 'package:serv_oeste/shared/widgets/screen/error_component.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/shared/widgets/screen/base_list_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ClienteScreen extends BaseListScreen<Cliente> {
  const ClienteScreen({super.key});

  @override
  BaseListScreenState<Cliente> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends BaseListScreenState<Cliente> {
  late final ClienteBloc _clienteBloc;
  late final TextEditingController _nomeController, _telefoneController, _enderecoController;

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
          keyboardType: TextInputType.text,
        ),
        TextInputField(
          hint: "Endereço...",
          controller: _enderecoController,
          keyboardType: TextInputType.text,
        ),
        TextInputField(
          hint: "Telefone...",
          controller: _telefoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  @override
  Widget getUpdateScreen(int id, {int? secondId}) => ClienteUpdateScreen(id: id);

  @override
  Widget buildDefaultFloatingActionButton() {
    return FloatingActionButtonAdd(
      route: Routes.clienteCreate,
      event: () => _clienteBloc.add(ClienteSearchMenuEvent()),
      tooltip: "Adicionar um Cliente",
    );
  }

  @override
  Widget buildSelectionFloatingActionButton(List<int> selectedIds) {
    return FloatingActionButtonRemove(
      removeMethod: () => disableSelectedItems(context, selectedIds),
      tooltip: "Excluir clientes Selecionados",
      content: 'Deletar clientes selecionados?',
    );
  }

  @override
  Widget buildItemCard(Cliente cliente, bool isSelected, bool isSelectMode, bool isSkeleton) {
    return ClienteCard(
      onDoubleTap: () => onNavigateToUpdateScreen(cliente.id!, () => _clienteBloc.add(ClienteSearchMenuEvent())),
      onLongPress: () => onSelectItemList(cliente.id!),
      onTap: () {
        if (isSelectMode) {
          onSelectItemList(cliente.id!);
        }
      },
      name: cliente.nome!,
      phoneNumber: cliente.telefoneFixo,
      cellphone: cliente.telefoneCelular,
      city: cliente.municipio!,
      street: cliente.endereco!,
      isSelected: isSelected,
      isSkeleton: isSkeleton,
    );
  }

  @override
  void searchFieldChanged() {
    _clienteBloc.add(
      ClienteSearchMenuEvent(
        nome: _nomeController.text,
        telefone: _telefoneController.text,
        endereco: _enderecoController.text,
      ),
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
            child: BlocConsumer<ClienteBloc, ClienteState>(
              listenWhen: (previous, current) => current is ClienteErrorState,
              listener: (context, state) {
                if (state is ClienteErrorState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Logger().e(state.error.detail);
                  });
                }
              },
              builder: (context, stateCliente) {
                if (stateCliente is ClienteInitialState || stateCliente is ClienteLoadingState) {
                  return Skeletonizer(
                    enableSwitchAnimation: true,
                    child: buildGridOfCards(
                      items: List.generate(16, (_) => Cliente()..applySkeletonData()),
                      aspectRatio: 1.55,
                      totalPages: 1,
                      currentPage: 0,
                      onPageChanged: (_) {},
                      isSkeleton: true,
                    ),
                  );
                } else if (stateCliente is ClienteSearchSuccessState) {
                  return buildGridOfCards(
                    items: stateCliente.clientes,
                    aspectRatio: 1.55,
                    totalPages: stateCliente.totalPages,
                    currentPage: stateCliente.currentPage,
                    onPageChanged: (page) {
                      _clienteBloc.add(ClienteLoadingEvent(
                        nome: _clienteBloc.nomeMenu,
                        telefone: _clienteBloc.telefoneMenu,
                        endereco: _clienteBloc.enderecoMenu,
                        page: page - 1,
                        size: 20,
                      ));
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 1400
                          ? 4
                          : MediaQuery.of(context).size.width > 1100
                              ? 3
                              : MediaQuery.of(context).size.width > 600
                                  ? 2
                                  : 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.55,
                    ),
                  );
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
