import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/pagination_widget.dart';
import 'package:serv_oeste/src/components/screen/entity_not_found.dart';
import 'package:serv_oeste/src/components/screen/error_component.dart';
import 'package:serv_oeste/src/components/screen/grid_view.dart';
import 'package:serv_oeste/src/components/screen/cards/card_service.dart';
import 'package:serv_oeste/src/components/screen/loading.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/screens/servico/update_servico.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void _onNavigateToUpdateScreen(int id, int clientId) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => UpdateServico(id: id, clientId: clientId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/heroImage.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Text(
              "Agenda da Semana",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(18.0, 26.0),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ServicoBloc, ServicoState>(
            builder: (context, stateServico) {
              if (stateServico is ServicoInitialState ||
                  stateServico is ServicoLoadingState) {
                return const Loading();
              } else if (stateServico is ServicoSearchSuccessState) {
                if (stateServico.servicos.isEmpty) {
                  return const EntityNotFound(
                      message: "Nenhum serviço agendado para essa semana",
                      icon: Icons.calendar_today);
                }
                return Column(
                  children: [
                    GridListView(
                      aspectRatio: .9,
                      dataList: stateServico.servicos,
                      buildCard: (dynamic servico) => CardService(
                        onDoubleTap: () => _onNavigateToUpdateScreen(servico.id, servico.idCliente),
                        cliente: (servico as Servico).nomeCliente,
                        codigo: servico.id,
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
                      ),
                    ),
                    if (stateServico.totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: PaginationWidget(
                          currentPage: stateServico.currentPage + 1,
                          totalPages: stateServico.totalPages,
                          onPageChanged: (page) {
                            DateTime today = DateTime.now();

                            DateTime startOfDay =
                                DateTime(today.year, today.month, today.day);
                            DateTime week = startOfDay.add(Duration(days: 7));

                            context.read<ServicoBloc>().add(
                                  ServicoInitialLoadingEvent(
                                    filterRequest: ServicoFilterRequest(
                                      dataAtendimentoPrevistoAntes: startOfDay,
                                      dataAtendimentoPrevistoDepois: week,
                                    ),
                                    page: page - 1,
                                    size: 10,
                                  ),
                                );
                          },
                        ),
                      ),
                  ],
                );
              }
              return const ErrorComponent();
            },
          ),
        ],
      ),
    );
  }
}
