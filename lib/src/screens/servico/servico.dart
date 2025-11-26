import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/layout/fab_remove.dart';
import 'package:serv_oeste/src/components/layout/responsive_search_inputs.dart';
import 'package:serv_oeste/src/components/screen/cards/card_service.dart';
import 'package:serv_oeste/src/components/screen/error_component.dart';
import 'package:serv_oeste/src/components/screen/expandable_fab_items.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/screens/base_list_screen.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/screens/servico/update_servico.dart';
import 'package:serv_oeste/src/shared/routing/routes.dart';
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
        TextInputField(hint: "Nome do Cliente...", controller: _nomeClienteController, keyboardType: TextInputType.text),
        TextInputField(hint: "Nome do Técnico...", controller: _nomeTecnicoController, keyboardType: TextInputType.text),
      ],
      onFilterTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => FilterService())).then((_) => onSearchFieldChanged()),
    );
  }

  @override
  Widget getUpdateScreen(int id, {int? secondId}) => UpdateServico(id: id, clientId: secondId!);

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
    return FloatingActionButtonRemove(removeMethod: () => disableSelectedItems(context, selectedIds), tooltip: "Excluir serviços selecionados");
  }

  @override
  Widget buildItemCard(Servico servico, bool isSelected, bool isSelectMode, bool isSkeleton) {
    return CardService(
        onDoubleTap: () => onNavigateToUpdateScreen(servico.id, onSearchFieldChanged, secondId: servico.idCliente),
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
        isSkeleton: isSkeleton);
  }

  @override
  void searchFieldChanged() {
    _servicoBloc.add(ServicoLoadingEvent(
        filterRequest: ServicoFilterRequest(
      clienteNome: _nomeClienteController.text,
      tecnicoNome: _nomeTecnicoController.text,
    )));
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

    _syncControllersWithBlocState();

    _servicoBloc.stream.listen((state) {
      if (state is ServicoSearchSuccessState) {
        _syncControllersWithBlocState();
      }
    });
    _setFilterValues();
  }

  void _syncControllersWithBlocState() {
    if (_servicoBloc.filterRequest != null) {
      _nomeClienteController.text = _servicoBloc.filterRequest!.clienteNome ?? "";
      _nomeTecnicoController.text = _servicoBloc.filterRequest!.tecnicoNome ?? "";
    } else {
      _nomeClienteController.text = "";
      _nomeTecnicoController.text = "";
    }
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
              listenWhen: (previous, current) => current is ServicoErrorState,
              listener: (context, state) {
                if (state is ServicoErrorState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Logger().e(state.error.detail);
                  });
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
                      _servicoBloc.add(ServicoLoadingEvent(
                        filterRequest: _servicoBloc.filterRequest ?? ServicoFilterRequest(),
                        page: page - 1,
                        size: 15,
                      ));
                    },
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
