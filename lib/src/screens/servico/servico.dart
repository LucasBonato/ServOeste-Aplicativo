import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/logic/list/list_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/components/card_service.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/components/expandable_fab_items.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';

class ServicoScreen extends StatefulWidget {
  const ServicoScreen({super.key});

  @override
  ServicoScreenState createState() => ServicoScreenState();
}

class ServicoScreenState extends State<ServicoScreen> {
  late final ServicoBloc _servicoBloc;
  late final ListBloc _listBloc;
  late final TextEditingController _nomeClienteController;
  late final TextEditingController _nomeTecnicoController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _servicoBloc = context.read<ServicoBloc>();
    _listBloc = context.read<ListBloc>();
    _nomeClienteController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
  }

  void _onNomeChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 150),
      () => _servicoBloc.add(
        ServicoLoadingEvent(
          filterRequest: ServicoFilterRequest(
            clienteNome: _nomeClienteController.text,
            tecnicoNome: _nomeTecnicoController.text,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInputs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final maxContainerWidth = 1200.0;

    Widget buildSearchField(
            {required String hint, TextEditingController? controller}) =>
        CustomSearchTextField(
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
      floatingActionButton: ExpandableFabItems(
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
                      aspectRatio: 1,
                      dataList: stateServico.servicos,
                      buildCard: (servico) => BlocBuilder<ListBloc, ListState>(
                        bloc: _listBloc,
                        builder: (context, stateList) {
                          bool isSelected = false;

                          if (stateList is ListSelectState) {
                            isSelected = stateList.selectedIds
                                .contains((servico as Servico).id);
                          }

                          return CardService(
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
// TODO - Criar um jeito de selecionar o card para possível edição ou mais ações no futuro. Não entendi o que vc quer fazer