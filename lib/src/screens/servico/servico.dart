import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/card_service.dart';
import 'package:serv_oeste/src/components/expandable_fab_items.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
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

  String? nomeCliente;
  String? nomeTecnico;

  final TextEditingController clientController = TextEditingController();
  final TextEditingController technicianController = TextEditingController();

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _servicoBloc.add(ServicoLoadingEvent(filterRequest: ServicoFilterRequest()));
  }

  @override
  void dispose() {
    clientController.dispose();
    technicianController.dispose();
    _servicoBloc.close();
    _clienteBloc.close();
    _tecnicoBloc.close();
    super.dispose();
  }

  void _applyFilters() {
    // _servicoBloc.add(
    //   ServicoFilterEvent(
    //     filterRequest: ServicoFilterRequest(
    //       cliente: clientController.text,
    //       tecnico: technicianController.text,
    //     ),
    //   ),
    // );
  }

  void _navigateToFilterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilterService()),
    );
  }

  Widget _buildSearchInputs(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;

    return Center(
      child: Container(
        width: isLargeScreen ? 1200.0 : double.infinity,
        padding: const EdgeInsets.all(5),
        child: isLargeScreen
            ? Row(
          children: [
            _buildSearchField(
              hint: 'Nome do Cliente...',
              controller: clientController,
              onChanged: _applyFilters,
            ),
            _buildSearchField(
              hint: 'Nome do Técnico...',
              controller: technicianController,
              onChanged: _applyFilters,
            ),
            _buildFilterIcon(),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField(
              hint: 'Nome do Cliente...',
              controller: clientController,
              onChanged: _applyFilters,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildSearchField(
                    hint: 'Nome do Técnico...',
                    controller: technicianController,
                    onChanged: _applyFilters,
                  ),
                ),
                _buildFilterIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({required String hint, required TextEditingController controller, required VoidCallback onChanged}) {
    return Expanded(
      child: SearchTextField(
        hint: hint,
        controller: controller,
        onChangedAction: (value) => onChanged(),
        leftPadding: 8,
        rightPadding: 8,
      ),
    );
  }

  Widget _buildFilterIcon() {
    return InkWell(
      onTap: () => _navigateToFilterPage(context),
      borderRadius: BorderRadius.circular(10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _isHovered ? const Color(0xFFF5EEED) : const Color(0xFFFFF8F7),
            border: Border.all(
              color: _isHovered ? const Color(0xFF6C757D) : const Color(0xFFEAE6E5),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.filter_list,
            size: 30.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Servico servico) {
    return CardService(
      cliente: nomeCliente!,
      tecnico: nomeTecnico!,
      equipamento: servico.equipamento,
      marca: servico.marca,
      local: servico.filial,
      data: servico.dataAtendimentoPrevisto,
      status: servico.situacao,
    );
  }

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
        updateList: () => _applyFilters(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //_buildSearchInputs(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<ServicoBloc, ServicoState>(
                bloc: _servicoBloc,
                builder: (context, state) {
                  // if (state is ServicoSearchSuccessState) {
                  //   return GridListView(
                  //     dataList: state.servicos,
                  //     buildCard: (data) => _buildServiceCard(data as Servico),
                  //   );
                  // }
                  // else {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  // }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}