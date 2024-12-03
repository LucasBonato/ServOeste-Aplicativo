import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/components/card_service.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/components/expandable_fab_items.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  final ServicoBloc _servicoBloc = ServicoBloc();
  final ClienteBloc _clienteBloc = ClienteBloc();
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();

  late final TextEditingController _nomeClienteController;
  late final TextEditingController _nomeTecnicoController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _nomeClienteController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
    _servicoBloc.add(ServicoLoadingEvent(filterRequest: ServicoFilterRequest()));
  }

  void _onNomeChanged() {
    if (_debounce?.isActive?? false) _debounce!.cancel();

    _debounce = Timer(
      Duration(milliseconds: 150),
      () => _servicoBloc.add(
        ServicoLoadingEvent(
          filterRequest: ServicoFilterRequest(
            clienteNome: _nomeClienteController.text,
            tecnicoNome: _nomeTecnicoController.text,
          ),
        ),
      )
    );
  }

  Widget _buildSearchInputs() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;

    return Container(
      width: isLargeScreen ? 1200.0 : double.infinity,
      padding: const EdgeInsets.all(5),
      child: isLargeScreen
          ? _buildLargeScreenLayout()
          : _buildSmallScreenLayout(),
    );
  }

  Widget _buildLargeScreenLayout() => Row(
    children: [
      _buildSearchField(
        hint: 'Nome do Cliente...',
        controller: _nomeClienteController,
      ),
      _buildSearchField(
        hint: 'Nome do Técnico...',
        controller: _nomeTecnicoController,
      ),
      _buildFilterIcon(),
    ],
  );

  Widget _buildSmallScreenLayout() => Column(
    children: [
      _buildSearchField(
        hint: 'Nome do Cliente...',
        controller: _nomeClienteController,
      ),
      Row(
        children: [
          Expanded(
            child: _buildSearchField(
              hint: 'Nome do Técnico...',
              controller: _nomeTecnicoController,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8, top: 4),
            child: _buildFilterIcon(),
          ),
        ],
      ),
    ],
  );

  Widget _buildFilterIcon() => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FilterService())),
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

  Widget _buildSearchField({required String hint, TextEditingController? controller}) => CustomSearchTextField(
    hint: hint,
    leftPadding: 8,
    rightPadding: 8,
    controller: controller,
    onChangedAction: (value) => _onNomeChanged(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ExpandableFabItems(
        firstHeroTag: 'add_service',
        secondHeroTag: 'add_service_cliente',
        firstRouterName: '/createService',
        secondRouterName: '/createServiceAndClient',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchInputs(),
            BlocBuilder<ServicoBloc, ServicoState>(
              bloc: _servicoBloc,
              builder: (context, state) {
                if (state is ServicoSearchSuccessState) {
                  return GridListView(
                    dataList: state.servicos,
                    buildCard: (servico) => CardService(
                      cliente: (servico as Servico).idCliente.toString(),
                      tecnico: servico.idTecnico.toString(),
                      equipamento: servico.equipamento,
                      marca: servico.marca,
                      local: servico.filial,
                      data: servico.dataAtendimentoPrevisto,
                      status: servico.situacao,
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator.adaptive());
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _servicoBloc.close();
    _clienteBloc.close();
    _tecnicoBloc.close();
    _debounce?.cancel();
    super.dispose();
  }
}