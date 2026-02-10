import 'dart:async';
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
  bool _shouldCancelOperation = false;
  int? _currentServicoId;

  Future<Servico?> _getCurrentServico() async {
    try {
      final servicoState = widget.servicoBloc.state;
      
      if (servicoState is ServicoSearchOneSuccessState) {
        return servicoState.servico;
      }
      
      if (_currentServicoId != null) {
        widget.servicoBloc.add(ServicoSearchOneEvent(id: _currentServicoId!));
        
        final completer = Completer<Servico?>();
        final subscription = widget.servicoBloc.stream.listen((state) {
          if (state is ServicoSearchOneSuccessState) {
            if (!completer.isCompleted) {
              completer.complete(state.servico);
            }
          } else if (state is ServicoErrorState) {
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        });

        final servico = await completer.future;
        await subscription.cancel();
        return servico;
      }
      
      return null;
    } catch (e) {
      Logger().e("Erro ao obter serviço atual: $e");
      return null;
    }
  }

  Future<Cliente?> _getCurrentCliente(int clienteId) async {
    try {
      final clienteState = widget.clienteBloc.state;
      
      if (clienteState is ClienteSearchOneSuccessState && 
          clienteState.cliente.id == clienteId) {
        return clienteState.cliente;
      }
      
      widget.clienteBloc.add(ClienteSearchOneEvent(id: clienteId));
      
      final completer = Completer<Cliente?>();
      final subscription = widget.clienteBloc.stream.listen((state) {
        if (state is ClienteSearchOneSuccessState) {
          if (!completer.isCompleted) {
            completer.complete(state.cliente);
          }
        } else if (state is ClienteErrorState) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        }
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      final cliente = await completer.future;
      await subscription.cancel();
      return cliente;
    } catch (e) {
      Logger().e("Erro ao obter cliente atual: $e");
      return null;
    }
  }

  Future<List<Servico>> _fetchHistoricoEquipamento(
      Servico servicoAtual, Cliente cliente) async {
    try {
      final filterRequest = ServicoFilter(
        equipamento: servicoAtual.equipamento,
        marca: servicoAtual.marca,
        clienteId: servicoAtual.idCliente,
      );

      widget.servicoBloc.add(ServicoSearchEvent(filter: filterRequest));

      final completer = Completer<ServicoState>();
      final subscription = widget.servicoBloc.stream.listen((state) {
        if (state is ServicoSearchSuccessState || state is ServicoErrorState) {
          if (!completer.isCompleted) {
            completer.complete(state);
          }
        }
      });

      final timeoutFuture = Future.delayed(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException("Tempo excedido ao buscar histórico"));
        }
      });

      ServicoState state;
      try {
        state = await completer.future;
      } finally {
        await subscription.cancel();
        timeoutFuture.ignore();
      }

      List<Servico> result = [];

      if (state is ServicoSearchSuccessState) {
        final List<Servico> response = state.servicos;
        
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
      } else if (state is ServicoErrorState) {
        Logger().e("Erro ao buscar histórico: ${state.error}");
      }

      return result;
    } on TimeoutException catch (e) {
      Logger().e("Timeout ao buscar histórico: ${e.message}");
      return [];
    } catch (e) {
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
    if (!mounted) return;

    setState(() {
      _isGeneratingPDF = true;
      _shouldCancelOperation = false;
    });

    Servico? servicoOriginal;
    Cliente? clienteOriginal;

    try {
      servicoOriginal = await _getCurrentServico();
      
      if (servicoOriginal == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Não foi possível carregar o serviço"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      _currentServicoId = servicoOriginal.id;
      
      clienteOriginal = await _getCurrentCliente(servicoOriginal.idCliente);
      
      if (clienteOriginal == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Não foi possível carregar o cliente"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final List<Servico> historico = await _fetchHistoricoEquipamento(
        servicoOriginal,
        clienteOriginal,
      );

      if (!mounted || _shouldCancelOperation) {
        return;
      }

      if (_currentServicoId != null) {
        widget.servicoBloc.add(ServicoSearchOneEvent(id: _currentServicoId!));
        await Future.delayed(const Duration(milliseconds: 100));
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
      if (mounted && !_shouldCancelOperation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao gerar PDF: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (!_shouldCancelOperation && _currentServicoId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.servicoBloc.add(ServicoSearchOneEvent(id: _currentServicoId!));
          }
        });
      }

      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final servicoState = widget.servicoBloc.state;
        if (servicoState is ServicoSearchOneSuccessState) {
          _currentServicoId = servicoState.servico.id;
        }
      }
    });
  }

  @override
  void dispose() {
    _shouldCancelOperation = true;
    super.dispose();
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
}