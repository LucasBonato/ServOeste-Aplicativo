import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/components/card_service.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ServicoBloc _servicoBloc = ServicoBloc();

  @override
  void initState() {
    _servicoBloc.add(ServicoLoadingEvent(filterRequest: ServicoFilterRequest(
      //dataAtendimentoPrevistoAntes: DateTime.now().toUtc()
    )));
    super.initState();
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
              "Agenda do Dia",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(18.0, 26.0),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ServicoBloc, ServicoState>(
            bloc: _servicoBloc,
            builder: (context, state) {
              if (state is ServicoSearchSuccessState) {
                return GridListView(
                  dataList: state.servicos,
                  buildCard: (dynamic servico) => CardService(
                    cliente: (servico as Servico).idCliente.toString(),
                    tecnico: servico.idTecnico.toString(),
                    equipamento: servico.equipamento,
                    marca: servico.marca,
                    local: servico.filial,
                    data: servico.dataAtendimentoPrevisto,
                    status: servico.situacao
                  ),
                );
              }
              else {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _servicoBloc.close();
    super.dispose();
  }
}
//TODO - Mostrar alguma menssagem quando não tiver serviços no dia, ou mostrar os da semana.