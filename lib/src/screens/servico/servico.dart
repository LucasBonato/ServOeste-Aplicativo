import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/screen/grid_view.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/components/screen/card_service.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/components/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/components/screen/expandable_fab_items.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/screens/servico/update_servico.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';

class ServicoScreen extends StatefulWidget {
  const ServicoScreen({super.key});

  @override
  ServicoScreenState createState() => ServicoScreenState();
}

class ServicoScreenState extends State<ServicoScreen> {
  late final ServicoBloc _servicoBloc;
  late final ListaBloc _listaBloc;
  late final TextEditingController _nomeClienteController;
  late final TextEditingController _nomeTecnicoController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _servicoBloc = context.read<ServicoBloc>();
    _listaBloc = context.read<ListaBloc>();
    _nomeClienteController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
  }

  void _onNomeChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 150), () {
      final filterRequest = ServicoFilterRequest(
        clienteNome: _nomeClienteController.text,
        tecnicoNome: _nomeTecnicoController.text,
      );
      _servicoBloc.add(ServicoLoadingEvent(filterRequest: filterRequest));
    });
  }

  void _onNavigateToUpdateScreen(int id) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => UpdateServico(id: id),
      ),
    );
    _listaBloc.add(ListaClearSelectionEvent());
  }

  void _onLongPressSelectItemList(int id) {
    _listaBloc.add(ListaToggleItemSelectEvent(id: id));
  }

  void _disableServicos(BuildContext context, List<int> selectedIds) {
    _servicoBloc.add(ServicoDisableListEvent(selectedList: selectedIds));
    _listaBloc.add(ListaClearSelectionEvent());
  }

  Widget _buildSearchInputs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final maxContainerWidth = 1200.0;

    Widget buildSearchField(
            {required String hint, TextEditingController? controller}) =>
        CustomSearchTextFormField(
          hint: hint,
          leftPadding: 4,
          rightPadding: 4,
          controller: controller,
          onChangedAction: (value) => _onNomeChanged(),
        );

    Widget buildFilterIcon() => InkWell(
          onTap: () => Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) => FilterService()))
              .then((_) => _onNomeChanged()),
          hoverColor: const Color(0xFFF5EEED),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFFFF8F7),
              border: Border.all(
                color: const Color(0xFFEAE6E5),
              ),
            ),
            child: const Icon(
              Icons.filter_list,
              size: 30.0,
              color: Colors.black,
            ),
          ),
        );

    Widget buildLargeScreenLayout() => Row(
          children: [
            Expanded(
              flex: 8,
              child: buildSearchField(
                hint: 'Nome do Cliente...',
                controller: _nomeClienteController,
              ),
            ),
            Expanded(
              flex: 8,
              child: buildSearchField(
                hint: 'Nome do Técnico...',
                controller: _nomeTecnicoController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4, top: 4, left: 4),
              child: buildFilterIcon(),
            ),
          ],
        );

    Widget buildSmallScreenLayout() => Column(
          children: [
            buildSearchField(
              hint: 'Nome do Cliente...',
              controller: _nomeClienteController,
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: buildSearchField(
                    hint: 'Nome do Técnico...',
                    controller: _nomeTecnicoController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4, top: 4, left: 4),
                  child: buildFilterIcon(),
                ),
              ],
            ),
          ],
        );

    return Container(
      width: isLargeScreen ? maxContainerWidth : double.infinity,
      padding: const EdgeInsets.all(5),
      child:
          isLargeScreen ? buildLargeScreenLayout() : buildSmallScreenLayout(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<ListaBloc, ListaState>(
        builder: (context, state) {
          final bool hasSelection =
              state is ListaSelectState && state.selectedIds.isNotEmpty;

          return !hasSelection
              ? ExpandableFabItems(
                  firstHeroTag: 'add_service',
                  secondHeroTag: 'add_service_cliente',
                  firstRouterName: '/createServico',
                  secondRouterName: '/createServico',
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
                  updateList: _onNomeChanged,
                )
              : BuildWidgets.buildFabRemove(
                  context,
                  () {
                    _disableServicos(context, state.selectedIds);
                    context.read<ListaBloc>().add(ListaClearSelectionEvent());
                  },
                  tooltip: 'Excluir serviços selecionados',
                );
        },
      ),
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocBuilder<ServicoBloc, ServicoState>(
              builder: (context, stateServico) {
                if (stateServico is ServicoInitialState ||
                    stateServico is ServicoLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                } else if (stateServico is ServicoSearchSuccessState) {
                  return SingleChildScrollView(
                    child: GridListView(
                      aspectRatio: .9,
                      dataList: stateServico.servicos,
                      buildCard: (servico) =>
                          BlocBuilder<ListaBloc, ListaState>(
                        bloc: _listaBloc,
                        builder: (context, stateLista) {
                          bool isSelected = false;

                          if (stateLista is ListaSelectState) {
                            isSelected = stateLista.selectedIds
                                .contains((servico as Servico).id);
                          }

                          return CardService(
                            onLongPress: () =>
                                _onLongPressSelectItemList(servico.id),
                            onDoubleTap: () =>
                                _onNavigateToUpdateScreen(servico.id),
                            cliente: (servico as Servico).nomeCliente,
                            tecnico: servico.nomeTecnico,
                            codigo: servico.id,
                            equipamento: servico.equipamento,
                            marca: servico.marca,
                            filial: servico.filial,
                            horario: servico.horarioPrevisto,
                            dataPrevista: servico.dataAtendimentoPrevisto,
                            dataAbertura: servico.dataAtendimentoAbertura,
                            dataEfetiva: servico.dataAtendimentoEfetivo,
                            garantia: servico.garantia,
                            status: servico.situacao,
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
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nomeClienteController.dispose();
    _nomeTecnicoController.dispose();
    super.dispose();
  }
}
