import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/layout/fab_remove.dart';
import 'package:serv_oeste/src/components/layout/pagination_widget.dart';
import 'package:serv_oeste/src/components/layout/responsive_search_inputs.dart';
import 'package:serv_oeste/src/components/screen/cards/card_service.dart';
import 'package:serv_oeste/src/components/screen/entity_not_found.dart';
import 'package:serv_oeste/src/components/screen/error_component.dart';
import 'package:serv_oeste/src/components/screen/expandable_fab_items.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/screens/base_list_screen.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/screens/servico/update_servico.dart';
import 'package:serv_oeste/src/shared/routes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ServicoScreen extends BaseListScreen<Servico> {
  const ServicoScreen({super.key});

  @override
  BaseListScreenState<Servico> createState() => _ServicoScreenState();
}

class _ServicoScreenState extends BaseListScreenState<Servico> {
  late final ServicoBloc _servicoBloc;
  late final TextEditingController _nomeClienteController;
  late final TextEditingController _nomeTecnicoController;

  void _setFilterValues() {
    if (_servicoBloc.filterRequest != null) {
      _nomeClienteController.text = _servicoBloc.filterRequest!.clienteNome ?? "";
      _nomeTecnicoController.text = _servicoBloc.filterRequest!.tecnicoNome ?? "";
    }
  }

  Widget _buildSearchInputs() {
    return ResponsiveSearchInputs(
      onChanged: onSearchFieldChanged,
      fields: [
        TextInputField(
            hint: "Nome do Cliente...",
            controller: _nomeClienteController,
            keyboardType: TextInputType.text
        ),
        TextInputField(
            hint: "Nome do Técnico...",
            controller: _nomeTecnicoController,
            keyboardType: TextInputType.text
        ),
      ],
      onFilterTap: () =>
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) => FilterService()))
              .then((_) => onSearchFieldChanged()),
    );
  }

  @override
  Widget getUpdateScreen(int id) => UpdateServico(id: id);

  @override
  Widget buildDefaultFloatingActionButton() {
    return ExpandableFabItems(
      firstHeroTag: 'add_service',
      secondHeroTag: 'add_service_cliente',
      firstRouterName: Routes.servicoCreate,
      secondRouterName: Routes.servicoCreate,
      firstTooltip: 'Adicionar Serviço',
      secondTooltip: 'Adicionar Serviço e Cliente',
      firstChild: Image.asset(
        'assets/addService.png',
        fit: BoxFit.contain,
        width: 36,
        height: 36,
      ),
      secondChild: const Icon(
        Icons.group_add,
        size: 36,
        color: Colors.white,
      ),
      updateList: onSearchFieldChanged,
    );
  }

  @override
  Widget buildSelectionFloatingActionButton(List<int> selectedIds) {
    return FloatingActionButtonRemove(
        removeMethod: () => disableSelectedItems(context, selectedIds),
        tooltip: "Excluir serviços selecionados"
    );
  }

  @override
  Widget buildItemCard(Servico servico, bool isSelected, bool isSelectMode, bool isSkeleton) {
    return CardService(
      onDoubleTap: () => onNavigateToUpdateScreen(servico.id, onSearchFieldChanged),
      onLongPress: () => onSelectItemList(servico.id),
      onTap: () {
        if (isSelectMode) {
          onSelectItemList(servico.id);
        }
      },
      codigo: servico.id,
      cliente: servico.nomeCliente,
      tecnico: servico.nomeTecnico,
      equipamento: servico.equipamento,
      marca: servico.marca,
      filial: servico.filial,
      horario: servico.horarioPrevisto,
      dataPrevista: servico.dataAtendimentoPrevisto,
      dataEfetiva: servico.dataAtendimentoEfetivo,
      dataFechamento: servico.dataFechamento,
      dataFinalGarantia: servico.dataFimGarantia,
      status: servico.situacao,
      isSelected: isSelected,
      isSkeleton: isSkeleton
    );
  }

  @override
  void searchFieldChanged() {
    _servicoBloc.add(
      ServicoLoadingEvent(
        filterRequest: ServicoFilterRequest(
          clienteNome: _nomeClienteController.text,
          tecnicoNome: _nomeTecnicoController.text,
        )
      )
    );
  }

  @override
  void onDisableItems(List<int> selectedIds) {
    _servicoBloc.add(ServicoDisableListEvent(selectedList: selectedIds));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Serviço deletado com sucesso! (Caso ele continue aparecendo, recarregue a página)',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _servicoBloc = context.read<ServicoBloc>();
    _nomeClienteController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
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
            child: BlocListener<ServicoBloc, ServicoState>(
              listenWhen: (previous, current) => current is ServicoErrorState,
              listener: (context, state) {
                if (state is ServicoErrorState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error.errorMessage),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                }
              },
              child: BlocBuilder<ServicoBloc, ServicoState>(
                builder: (context, stateServico) {
                  if (stateServico is ServicoInitialState || stateServico is ServicoLoadingState) {
                    return Skeletonizer(
                      enableSwitchAnimation: true,
                      child: buildGridOfCards(
                        List.generate(8, (_) => Servico.skeleton()),
                        0.9,
                        isSkeleton: true,
                      ),
                    );
                  }
                  else if (stateServico is ServicoSearchSuccessState) {
                    return Column(
                      children: [
                        Expanded(
                          child: stateServico.servicos.isNotEmpty
                              ? buildGridOfCards(stateServico.servicos, 0.9)
                              : const EntityNotFound(message: "Nenhum serviço encontrado."),
                        ),
                        if (stateServico.totalPages > 1)
                          PaginationWidget(
                            currentPage: stateServico.currentPage + 1,
                            totalPages: stateServico.totalPages,
                            onPageChanged: (page) {
                              _servicoBloc.add(ServicoLoadingEvent(
                                filterRequest: _servicoBloc.filterRequest ??
                                    ServicoFilterRequest(),
                                page: page - 1,
                                size: 15,
                              ));
                            },
                          ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  else if (stateServico is ServicoSearchSuccessState) {
                    if (stateServico.servicos.isNotEmpty) {
                      return buildGridOfCards(stateServico.servicos, 0.9);
                    }
                    return const EntityNotFound(message: "Nenhum serviço encontrado.");
                  }
                  return const ErrorComponent();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _nomeTecnicoController.dispose();
    super.dispose();
  }
}
