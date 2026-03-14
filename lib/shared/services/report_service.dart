import 'package:logger/logger.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter.dart';
import 'package:serv_oeste/features/servico/domain/servico_repository.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';
import 'package:serv_oeste/shared/pdf/reports/orcamento_report.dart';
import 'package:serv_oeste/shared/pdf/reports/pdf_report.dart';
import 'package:serv_oeste/shared/pdf/reports/recibo_report.dart';
import 'package:serv_oeste/shared/pdf/reports/report_type.dart';
import 'package:serv_oeste/shared/pdf/reports/visitas_report.dart';

class ReportService {
  final ServicoRepository servicoRepository;

  ReportService(this.servicoRepository);

  Future<void> generate({required ReportType type, required Servico servico, required Cliente cliente}) async {
    final pw.ImageProvider logo = await imageFromAssetBundle('assets/servOeste.png');

    final PdfReport report = switch (type) {
      ReportType.orcamento => OrcamentoReport(
        servico: servico,
        cliente: cliente,
        logo: logo,
      ),
      ReportType.recibo => ReciboReport(
        servico: servico,
        cliente: cliente,
        logo: logo,
      ),
      ReportType.visitas => VisitasReport(
        servico: servico,
        cliente: cliente,
        historicoServicos: await fetchHistoricoEquipamento(servico),
        logo: logo,
      ),
    };

    await report.generate();
  }

  Future<List<Servico>> fetchHistoricoEquipamento(Servico servicoAtual) async {
    try {
      final filter = ServicoFilter(
        equipamento: servicoAtual.equipamento,
        marca: servicoAtual.marca,
        clienteId: servicoAtual.idCliente
      );
      final result = await servicoRepository.getServicosByFilter(filter: filter, page: 0, size: 100);
      return result.fold(
        (ErrorEntity error) {
          Logger().e("Erro ao buscar histórico: ${error.title}");
          return [];
        },
        (PageContent<Servico> pageContent) {
          final List<Servico> response = pageContent.content;

          final List<Servico> filtered = response.where((servico) {
            if (servico.id == servicoAtual.id) {
              return false;
            }

            final String marcaAtual = _normalize(servicoAtual.marca);
            final String marcaServico = _normalize(servico.marca);
            final String equipamentoAtual = _normalize(servicoAtual.equipamento);
            final String equipamentoServico = _normalize(servico.equipamento);

            final bool marcaMatch = marcaAtual == marcaServico;
            final bool equipamentoMatch = equipamentoAtual == equipamentoServico;
            final bool clienteMatch = servico.idCliente == servicoAtual.idCliente;

            return marcaMatch && equipamentoMatch && clienteMatch;
          }).toList();

          filtered.sort((a, b) {
            final DateTime dateA = a.dataAtendimentoAbertura ?? DateTime(1900);
            final DateTime dateB = b.dataAtendimentoAbertura ?? DateTime(1900);
            return dateB.compareTo(dateA);
          });

          return filtered;
        },
      );
    } catch (e, stackTrace) {
      Logger().e("Erro inesperado ao buscar histórico", error: e, stackTrace: stackTrace);
      return [];
    }
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(' ', '');
  }
}
