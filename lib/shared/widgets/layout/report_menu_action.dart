import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/shared/pdfs/orcamento_pdf.dart';
import 'package:serv_oeste/shared/pdfs/recibo_pdf.dart';
import 'package:serv_oeste/shared/pdfs/relatorio_visitas_pdf.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';

class ReportMenuActionButton extends StatefulWidget {
  final ServicoBloc servicoBloc;
  final ClienteBloc clienteBloc;

  const ReportMenuActionButton({
    super.key,
    required this.servicoBloc,
    required this.clienteBloc,
  });

  @override
  State<ReportMenuActionButton> createState() => _ReportMenuActionButtonState();
}

class _ReportMenuActionButtonState extends State<ReportMenuActionButton> {
  bool _isGeneratingPDF = false;

  bool _menuIsOpen = false;

  Future<List<Servico>> _fetchHistoricoEquipamento(
      Servico servicoAtual, Cliente cliente) async {
    try {
      final filterRequest = ServicoFilter(
        equipamento: servicoAtual.equipamento,
        marca: servicoAtual.marca,
        clienteId: servicoAtual.idCliente,
      );

      Logger().d("FILTRO PARA ServicoClient:");
      Logger().d("  • clienteId: ${filterRequest.clienteId}");
      Logger().d("  • marca: ${filterRequest.marca}");
      Logger().d("  • equipamento: ${filterRequest.equipamento}");

      widget.servicoBloc.add(ServicoSearchEvent(filter: filterRequest));

      await widget.servicoBloc.stream.firstWhere((state) {
        return state is ServicoSearchSuccessState || state is ServicoErrorState;
      });

      List<Servico> result = [];

      if (widget.servicoBloc.state is ServicoSearchSuccessState) {
        final List<Servico> response =
            (widget.servicoBloc.state as ServicoSearchSuccessState).servicos;

        Logger().d("RESULTADO DA BUSCA:");
        Logger().d("Total de serviços retornados: ${response.length}");

        final filtered = response.where((servico) {
          if (servico.id == servicoAtual.id) {
            return false;
          }

          final marcaAtual =
              servicoAtual.marca.toLowerCase().replaceAll(' ', '');
          final marcaServico = servico.marca.toLowerCase().replaceAll(' ', '');
          final equipamentoAtual =
              servicoAtual.equipamento.toLowerCase().replaceAll(' ', '');
          final equipamentoServico =
              servico.equipamento.toLowerCase().replaceAll(' ', '');

          final bool marcaMatch = marcaAtual == marcaServico;
          final bool equipamentoMatch = equipamentoAtual == equipamentoServico;
          final bool clienteMatch = servico.idCliente == servicoAtual.idCliente;

          return marcaMatch && equipamentoMatch && clienteMatch;
        }).toList();

        filtered.sort((a, b) {
          final dateA = a.dataAtendimentoAbertura ?? DateTime(1900);
          final dateB = b.dataAtendimentoAbertura ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        result = filtered;
      } else if (widget.servicoBloc.state is ServicoErrorState) {
        widget.servicoBloc.state as ServicoErrorState;
      }

      widget.servicoBloc.add(ServicoSearchEvent(
        filter: ServicoFilter(),
        page: 0,
      ));

      return result;
    } catch (e) {
      widget.servicoBloc.add(ServicoSearchEvent(
        filter: ServicoFilter(),
        page: 0,
      ));

      Logger().e("Erro ao buscar histórico: $e");
      return [];
    }
  }

  Future<void> _showMenu() async {
    if (_isGeneratingPDF || _menuIsOpen || !mounted) {
      return;
    }

    setState(() {
      _menuIsOpen = true;
    });

    try {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        return;
      }

      final Offset offset = renderBox.localToGlobal(Offset.zero);

      final String? result = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + renderBox.size.height,
          offset.dx + renderBox.size.width,
          offset.dy + renderBox.size.height,
        ),
        items: [
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
      ).whenComplete(() {
        if (mounted) {
          setState(() {
            _menuIsOpen = false;
          });
        }
      });

      if (result != null && mounted) {
        await _handleMenuSelection(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _menuIsOpen = false;
        });
      }
    }
  }

  Future<void> _handleMenuSelection(String value) async {
    setState(() {
      _isGeneratingPDF = true;
    });

    Servico? servicoOriginal;
    Cliente? clienteOriginal;

    try {
      final ServicoState servicoState = context.read<ServicoBloc>().state;
      final ClienteState clienteState = context.read<ClienteBloc>().state;

      if (servicoState is! ServicoSearchOneSuccessState) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Serviço não carregado. Estado atual: ${servicoState.runtimeType}"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (clienteState is! ClienteSearchOneSuccessState) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Cliente não carregado. Estado atual: ${clienteState.runtimeType}"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      servicoOriginal = servicoState.servico;
      clienteOriginal = clienteState.cliente;

      final List<Servico> historico = await _fetchHistoricoEquipamento(
        servicoOriginal,
        clienteOriginal,
      );

      await widget.servicoBloc.stream
          .firstWhere(
        (state) =>
            state is ServicoSearchOneSuccessState || state is ServicoErrorState,
      )
          .catchError((error) {
        return ServicoErrorState(error: error);
      });

      final currentState = widget.servicoBloc.state;
      if (currentState is ServicoSearchOneSuccessState) {
        servicoOriginal = currentState.servico;
      }

      switch (value) {
        case 'gerarOrcamento':
          await generateOrcamentoPDF(
            servico: servicoOriginal,
            cliente: clienteOriginal,
          );
          break;
        case 'gerarRecibo':
          await generateReciboPDF(
            servico: servicoOriginal,
            cliente: clienteOriginal,
          );
          break;
        case 'relatorioVisitas':
          await generateChamadoTecnicoPDF(
            servico: servicoOriginal,
            cliente: clienteOriginal,
            historicoEquipamento: historico,
          );
          break;
      }
    } catch (e) {
      if (servicoOriginal != null) {
        widget.servicoBloc.add(ServicoSearchOneEvent(id: servicoOriginal.id));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao gerar PDF: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: _isGeneratingPDF
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              tooltip: 'Mostrar opções de PDFs',
              onPressed: _showMenu,
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
