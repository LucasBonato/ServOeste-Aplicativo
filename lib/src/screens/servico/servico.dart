import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
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
  late final TextEditingController _nomeClienteController;
  late final TextEditingController _nomeTecnicoController;
  Timer? _debounce;
  late final List<int> _selectedItems;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _servicoBloc = context.read<ServicoBloc>();
    _nomeClienteController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
  }

  void _onNomeChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      Duration(milliseconds: 150),
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

  void _disableServico() {
    // final List<int> selectedItemsCopy = List<int>.from(_selectedItems);
    // _servicoBloc.add(_deleteService(selectedList: selectedItemsCopy));
    setState(() {
      _selectedItems.clear();
      isSelected = false;
    });
  }

  void _selectItems(int id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }

      isSelected = _selectedItems.isNotEmpty;
    });
  }

  Widget _buildSearchInputs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final maxContainerWidth = 1200.0;

    Widget buildSearchField(
            {required String hint, TextEditingController? controller}) =>
        CustomSearchTextField(
          hint: hint,
          leftPadding: 8,
          rightPadding: 8,
          controller: controller,
          onChangedAction: (value) => _onNomeChanged(),
        );

    Widget buildFilterIcon() => InkWell(
          onTap: () => Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) => FilterService())),
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
            Expanded(child: buildFilterIcon()),
          ],
        );

    Widget buildSmallScreenLayout() => Column(
          children: [
            buildSearchField(
              hint: 'Nome do Cliente...',
              controller: _nomeClienteController,
            ),
            Row(
              children: [
                Expanded(
                  child: buildSearchField(
                    hint: 'Nome do Técnico...',
                    controller: _nomeTecnicoController,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8, top: 4),
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
              builder: (context, state) {
                if (state is ServicoSearchSuccessState) {
                  return SingleChildScrollView(
                    child: GridListView(
                      aspectRatio: 1.5,
                      dataList: state.servicos,
                      buildCard: (servico) => CardService(
                        cliente: (servico as Servico).nomeCliente,
                        tecnico: servico.nomeTecnico,
                        equipamento: servico.equipamento,
                        marca: servico.marca,
                        local: servico.filial,
                        data: servico.dataAtendimentoPrevisto,
                        status: servico.situacao,
                      ),
                    ),
                  );
                }
                return const Center(
                    child: CircularProgressIndicator.adaptive());
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
    super.dispose();
  }
}
//TODO - Criar um jeito de selecionar o card para possível edição ou mais ações no futuro. Não entendi o que vc quer fazer