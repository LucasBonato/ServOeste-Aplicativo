import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/pdfs/orcamento_pdf.dart';
import 'package:serv_oeste/src/pdfs/recibo_pdf.dart';
import 'package:serv_oeste/src/pdfs/relatorio_visitas_pdf.dart';

class ReportMenuActionButton extends StatelessWidget {
  final ServicoBloc servicoBloc;
  final ClienteBloc clienteBloc;

  const ReportMenuActionButton({
    super.key,
    required this.servicoBloc,
    required this.clienteBloc,
  });

  Future<List<Servico>> _fetchHistoricoEquipamento(Servico servicoAtual, Cliente cliente) async {
    try {
      final filterRequest = ServicoFilterRequest(
        equipamento: servicoAtual.equipamento,
        marca: servicoAtual.equipamento,
        clienteId: servicoAtual.idCliente,
      );

      servicoBloc.add(ServicoSearchMenuEvent(filterRequest: filterRequest));

      await servicoBloc.stream.firstWhere((state) => state is ServicoSearchSuccessState || state is ServicoErrorState);

      if (servicoBloc.state is ServicoSearchSuccessState) {
        final List<Servico> response = (servicoBloc.state as ServicoSearchSuccessState).servicos;

        return response.where((servico) {
          final marcaAtual = servicoAtual.marca.toLowerCase().replaceAll(' ', '');
          final marcaServico = servico.marca.toLowerCase().replaceAll(' ', '');
          return marcaAtual == marcaServico && servico.id != servicoAtual.id;
        }).toList();
      }

      return [];
    } catch (e) {
      Logger().e("Erro ao buscar histórico: $e");
      return [];
    }
  }

  Future<void> _handleMenuSelection({required String value, required Servico servico, required Cliente cliente, required List<Servico> historicoEquipamento}) async {
    switch (value) {
      case 'gerarOrcamento':
        await generateOrcamentoPDF(
          servico: servico,
          cliente: cliente,
        );
        break;

      case 'gerarRecibo':
        await generateReciboPDF(
          servico: servico,
          cliente: cliente,
        );
        break;

      case 'relatorioVisitas':
        await generateChamadoTecnicoPDF(
          servico: servico,
          cliente: cliente,
          historicoEquipamento: historicoEquipamento,
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.black),
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'gerarOrcamento',
            child: Text('Gerar Orçamento'),
          ),
          const PopupMenuItem<String>(
            value: 'gerarRecibo',
            child: Text('Gerar Recibo'),
          ),
          const PopupMenuItem<String>(
            value: 'relatorioVisitas',
            child: Text('Gerar Relatório de Visitas'),
          ),
        ],
        onSelected: (String value) async {
          final ServicoState servicoState = context.read<ServicoBloc>().state;
          final ClienteState clienteState = context.read<ClienteBloc>().state;

          if (servicoState is! ServicoSearchOneSuccessState || clienteState is! ClienteSearchOneSuccessState) return;

          final List<Servico> historico = await _fetchHistoricoEquipamento(servicoState.servico, clienteState.cliente);

          await _handleMenuSelection(
            value: value,
            servico: servicoState.servico,
            cliente: clienteState.cliente,
            historicoEquipamento: historico
          );
        },
      ),
    );
  }
}
