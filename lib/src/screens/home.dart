import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/screen/grid_view.dart';
import 'package:serv_oeste/src/components/screen/card_service.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                        Colors.black.withOpacity(0.7),
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
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              } else if (stateServico is ServicoSearchSuccessState) {
                if (stateServico.servicos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Nenhum serviço agendado para essa semana",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return GridListView(
                  aspectRatio: .9,
                  dataList: stateServico.servicos,
                  buildCard: (dynamic servico) => CardService(
                    cliente: (servico as Servico).nomeCliente,
                    codigo: servico.id,
                    tecnico: servico.nomeTecnico,
                    equipamento: servico.equipamento,
                    marca: servico.marca,
                    filial: servico.filial,
                    horario: servico.horarioPrevisto,
                    dataPrevista: servico.dataAtendimentoPrevisto,
                    dataEfetiva: servico.dataAtendimentoEfetivo,
                    dataAbertura: servico.dataAtendimentoAbertura,
                    status: servico.situacao,
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
        ],
      ),
    );
  }
}
