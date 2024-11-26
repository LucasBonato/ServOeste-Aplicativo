import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class Servico extends StatefulWidget {
  const Servico({super.key});

  @override
  State<Servico> createState() => _ServicoState();
}

class _ServicoState extends State<Servico> {
  final ServicoBloc _servicoBloc = ServicoBloc();

  @override
  void initState() {
    _servicoBloc.add(ServicoLoadingEvent(filterRequest: ServicoFilterRequest()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicoBloc, ServicoState>(
      bloc: _servicoBloc,
      buildWhen: (previous, current) => current is ServicoSearchSuccessState,
      builder: (context, state) {
        return switch (state) {
          ServicoSearchSuccessState() => SuperListView.builder(
            itemCount: state.servicos.length,
            itemBuilder: (context, index) => ListTile(
              leading: Text(state.servicos[index].id.toString()),
              title: Text('${state.servicos[index].dataAtendimentoPrevisto.day < 10 ? '0${state.servicos[index].dataAtendimentoPrevisto.day}' : state.servicos[index].dataAtendimentoPrevisto.day}/${state.servicos[index].dataAtendimentoPrevisto.month < 10 ? '0${state.servicos[index].dataAtendimentoPrevisto.month}' : state.servicos[index].dataAtendimentoPrevisto.month}/${state.servicos[index].dataAtendimentoPrevisto.year}'),
              trailing: Text(state.servicos[index].situacao),
            ),
          ),

          _ => const Center(child: CircularProgressIndicator.adaptive())
        };
      },
    );
  }
}

