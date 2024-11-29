import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/card_service.dart';
import 'package:serv_oeste/src/components/expandable_fab.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/screens/servico/filter_servico.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  bool _isHovered = false;
  List<Map<String, String>> serviceList = List.generate(
    10,
    (index) => {
      'cliente': 'Jefferson Oliveira',
      'equipamento': 'Geladeira',
      'marca': 'Consul',
      'tecnico': 'Lucas Adriano',
      'local': 'Osasco',
      'data': '11/11/2024 - Tarde',
      'status': 'Aguardando Orçamento',
    },
  );

  TextEditingController clientController = TextEditingController();
  TextEditingController technicianController = TextEditingController();

  void _applyFilters() {
    setState(() {
      serviceList = serviceList.where((service) {
        bool matchesClient = service['cliente']!
            .toLowerCase()
            .contains(clientController.text.toLowerCase());
        bool matchesTechnician = service['tecnico']!
            .toLowerCase()
            .contains(technicianController.text.toLowerCase());
        return matchesClient && matchesTechnician;
      }).toList();
    });
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
                  Expanded(
                    flex: 3,
                    child: SearchTextField(
                      hint: 'Nome do Cliente...',
                      controller: clientController,
                      onChangedAction: (value) => _applyFilters(),
                      leftPadding: 8,
                      rightPadding: 8,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SearchTextField(
                      hint: 'Nome do Técnico...',
                      controller: technicianController,
                      onChangedAction: (value) => _applyFilters(),
                      leftPadding: 8,
                      rightPadding: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _navigateToFilterPage(context),
                    borderRadius: BorderRadius.circular(10),
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _isHovered = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _isHovered = false;
                        });
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _isHovered
                              ? const Color(0xFFF5EEED)
                              : const Color(0xFFFFF8F7),
                          border: Border.all(
                            color: _isHovered
                                ? const Color(0xFF6C757D)
                                : const Color(0xFFEAE6E5),
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
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: SearchTextField(
                      hint: 'Nome do Cliente...',
                      controller: clientController,
                      onChangedAction: (value) => _applyFilters(),
                      leftPadding: 8,
                      rightPadding: 8,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SearchTextField(
                          hint: 'Nome do Técnico...',
                          controller: technicianController,
                          onChangedAction: (value) => _applyFilters(),
                          leftPadding: 8,
                          rightPadding: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _navigateToFilterPage(context),
                        borderRadius: BorderRadius.circular(10),
                        child: MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _isHovered = true;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _isHovered = false;
                            });
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _isHovered
                                  ? const Color(0xFFF5EEED)
                                  : const Color(0xFFFFF8F7),
                              border: Border.all(
                                color: _isHovered
                                    ? const Color(0xFF6C757D)
                                    : const Color(0xFFEAE6E5),
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
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildServiceCard(dynamic data) {
    return CardService(
      cliente: data['cliente'],
      equipamento: data['equipamento'],
      marca: data['marca'],
      tecnico: data['tecnico'],
      local: data['local'],
      data: data['data'],
      status: data['status'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchInputs(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridListView(
                dataList: serviceList,
                buildCard: _buildServiceCard,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandableFab(
        distance: 100,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context)
                .pushNamed('/createService')
                .then((_) => setState(() {})),
            heroTag: 'add_service',
            tooltip: 'Adicionar Serviço',
            backgroundColor: Colors.blue,
            shape: CircleBorder(),
            child: Image.asset(
              'assets/addService.png',
              fit: BoxFit.contain,
              width: 36,
              height: 36,
            ),
          ),
          FloatingActionButton(
            onPressed: () => Navigator.of(context)
                .pushNamed('/createServiceAndClient')
                .then((_) => setState(() {})),
            heroTag: 'add_service_cliente',
            tooltip: 'Adicionar Serviço e Cliente',
            backgroundColor: Colors.blue, // Cor de fundo azul
            shape: CircleBorder(),
            child: const Icon(
              Icons.group_add,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
