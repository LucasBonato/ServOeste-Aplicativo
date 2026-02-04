import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/core/routing/args/servico_create_args.dart';
import 'package:serv_oeste/core/routing/args/servico_filter_form_args.dart';
import 'package:serv_oeste/core/routing/args/servico_update_args.dart';
import 'package:serv_oeste/core/routing/routes.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter_form.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/features/servico/presentation/widgets/servico_card.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_input_field.dart';
import 'package:serv_oeste/shared/widgets/layout/fab_remove.dart';
import 'package:serv_oeste/shared/widgets/layout/responsive_search_inputs.dart';
import 'package:serv_oeste/shared/widgets/screen/base_list_screen.dart';
import 'package:serv_oeste/shared/widgets/screen/error_component.dart';
import 'package:serv_oeste/shared/widgets/screen/expandable_fab_items.dart';
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

  Widget _buildSearchInputs() {
    return ResponsiveSearchInputs(
      onChanged: onSearchFieldChanged,
      fields: [
        TextInputField(
          hint: "Nome do Cliente...",
          controller: _nomeClienteController,
          keyboardType: TextInputType.text,
        ),
        TextInputField(
          hint: "Nome do Técnico...",
          controller: _nomeTecnicoController,
          keyboardType: TextInputType.text,
        ),
      ],
      onFilterTap: () async {
        final ServicoFilterForm form = ServicoFilterForm();

        await Navigator.of(context, rootNavigator: true).pushNamed(Routes.servicoFilter,
            arguments: ServicoFilterFormArgs(
              form: form,
              bloc: _servicoBloc,
              submitText: "Filtrar",
              title: "Filtrar Serviços",
            ));
      },
    );
  }

  @override
  String getUpdateRoute() => Routes.servicoUpdate;

  @override
  Widget buildDefaultFloatingActionButton() {
    return ExpandableFabItems(
      firstHeroTag: 'add_service',
      firstRouterName: Routes.servicoCreate,
      firstTooltip: 'Adicionar Serviço',
      firstArgs: ServicoCreateArgs(isClientAndService: false),
      firstChild: Image.asset(
        'assets/addService.png',
        fit: BoxFit.contain,
        width: 36,
        height: 36,
      ),
      secondHeroTag: 'add_service_cliente',
      secondRouterName: Routes.servicoCreate,
      secondTooltip: 'Adicionar Serviço e Cliente',
      secondArgs: ServicoCreateArgs(isClientAndService: true),
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
      tooltip: "Excluir serviços selecionados",
      content: 'Deletar serviços selecionados?',
    );
  }

  @override
  Widget buildItemCard(Servico servico, bool isSelected, bool isSelectMode, bool isSkeleton) {
    return ServicoCard(
      onDoubleTap: () => onNavigateToUpdateScreen(
        ServicoUpdateArgs(id: servico.id, clientId: servico.idCliente),
        onSearchFieldChanged,
      ),
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
      isSkeleton: isSkeleton,
    );
  }

  @override
  void searchFieldChanged() {
    _servicoBloc.add(
      ServicoSearchEvent(
        filter: ServicoFilter(
          clienteNome: _nomeClienteController.text,
          tecnicoNome: _nomeTecnicoController.text,
        ),
      ),
    );
  }

  @override
  void onDisableItems(List<int> selectedIds) {
    _servicoBloc.add(ServicoDisableListEvent(selectedList: selectedIds));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Serviço deletado com sucesso! (Caso ele não esteja deletado, recarregue a página)',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _servicoBloc = context.read<ServicoBloc>();
    _nomeClienteController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
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
            child: BlocConsumer<ServicoBloc, ServicoState>(
              listenWhen: (previous, current) => current is ServicoErrorState ||
                  (
                    current is ServicoSearchSuccessState &&
                    previous is ServicoSearchSuccessState &&
                    current.filter != previous.filter
                  ),
              listener: (context, state) {
                if (state is ServicoErrorState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Logger().e(state.error.detail);
                  });
                }
                if (state is ServicoSearchSuccessState) {
                  final ServicoFilter filter = state.filter;
                  _nomeClienteController.text = filter.clienteNome ?? "";
                  _nomeTecnicoController.text = filter.tecnicoNome ?? "";
                }
              },
              builder: (context, stateServico) {
                if (stateServico is ServicoInitialState || stateServico is ServicoLoadingState) {
                  return Skeletonizer(
                    enableSwitchAnimation: true,
                    child: buildGridOfCards(
                      items: List.generate(8, (_) => Servico.skeleton()),
                      aspectRatio: 0.9,
                      totalPages: 1,
                      currentPage: 0,
                      onPageChanged: (_) {},
                      isSkeleton: true,
                    ),
                  );
                }
                if (stateServico is ServicoSearchSuccessState) {
                  return buildGridOfCards(
                    items: stateServico.servicos,
                    aspectRatio: 0.9,
                    totalPages: stateServico.totalPages,
                    currentPage: stateServico.currentPage,
                    onPageChanged: (page) {
                      _servicoBloc.add(
                        ServicoSearchEvent(
                          filter: stateServico.filter,
                          page: page - 1,
                          size: 15,
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 1400
                          ? 4
                          : MediaQuery.of(context).size.width > 1000
                              ? 3
                              : MediaQuery.of(context).size.width > 500
                                  ? 2
                                  : 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                  );
                }
                return const ErrorComponent();
              },
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
