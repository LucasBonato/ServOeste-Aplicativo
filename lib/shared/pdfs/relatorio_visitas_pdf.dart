import 'package:logger/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';
import 'pdf_base.dart';

Future<void> generateChamadoTecnicoPDF({
  required Servico servico,
  required Cliente cliente,
  required List<Servico> historicoEquipamento,
}) async {
  try {
    final pdf = await PDFBase.createDocument();
    final logo = await imageFromAssetBundle('assets/servOeste.png');
    final outputFileName = 'relatorioVisitas_${servico.id}.pdf';

    final historicoFiltrado =
        historicoEquipamento.where((s) => s.id != servico.id).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          try {
            final primeirosServicos = historicoFiltrado.length > 3
                ? historicoFiltrado.sublist(0, 3)
                : historicoFiltrado;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                PDFBase.buildHeader(logo),
                pw.SizedBox(height: 20),
                PDFBase.buildTitle('CHAMADO ATUAL - Nº ${servico.id}'),
                pw.SizedBox(height: 10),
                _buildServiceInfoSection(servico, cliente),
                pw.SizedBox(height: 10),
                if (historicoFiltrado.isEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 10),
                    child: pw.Text(
                      '*ESTE É O PRIMEIRO SERVIÇO DO CLIENTE PARA ESTE EQUIPAMENTO.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                if (historicoFiltrado.isNotEmpty)
                  _buildHistoricoSection(primeirosServicos, servico.id),
                if (historicoFiltrado.length > 3)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 10),
                    child: pw.Text(
                      '*Mostrando 3 serviços mais recentes de ${historicoFiltrado.length} encontrados',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            );
          } catch (e) {
            Logger().e("Erro ao construir página PDF: $e");
            return pw.Center(
              child: pw.Text('Erro ao gerar PDF: $e'),
            );
          }
        },
      ),
    );

    if (historicoFiltrado.length > 3) {
      final servicosRestantes = historicoFiltrado.sublist(3);
      final totalPaginasAdicionais = (servicosRestantes.length / 5).ceil();

      for (int pagina = 0; pagina < totalPaginasAdicionais; pagina++) {
        final inicio = pagina * 5;
        final fim = (inicio + 5) > servicosRestantes.length
            ? servicosRestantes.length
            : inicio + 5;

        final servicosPagina = servicosRestantes.sublist(inicio, fim);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Continuação do histórico (serviços ${inicio + 4}-${fim + 3})',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  for (var servico in servicosPagina)
                    _buildHistoricoTable(servico),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Página ${pagina + 2}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    textAlign: pw.TextAlign.left,
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    await PDFBase.savePdfAutomatically(
      pdf: pdf,
      fileName: outputFileName,
    );
  } catch (e) {
    throw Exception("Erro ao gerar PDF do relatório de visitas: $e");
  }
}

pw.Widget _buildServiceInfoSection(Servico servico, Cliente cliente) {
  return pw.Column(
    children: [
      PDFBase.buildClientServiceTable(servico, cliente),
      PDFBase.buildDescriptionSection(servico.descricao),
    ],
  );
}

pw.Widget _buildHistoricoSection(List<Servico> historico, int servicoAtualId) {
  final historicoFiltrado =
      historico.where((s) => s.id != servicoAtualId).toList();

  if (historicoFiltrado.isEmpty) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        '*ESTE É O PRIMEIRO SERVIÇO DO CLIENTE PARA ESTE EQUIPAMENTO.',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 10,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  return _buildHistoricoEquipamento(historicoFiltrado);
}

pw.Widget _buildHistoricoEquipamento(List<Servico> historico) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 15),
      pw.Text(
        'HISTÓRICO DESTE EQUIPAMENTO',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 10),
      for (var servico in historico) _buildHistoricoTable(servico),
    ],
  );
}

pw.Widget _buildHistoricoTable(Servico servico) {
  DateTime? effectiveDate =
      Formatters.extractDateFromDescription(servico.descricao);

  if (effectiveDate == null && servico.dataAtendimentoPrevisto != null) {
    effectiveDate = servico.dataAtendimentoPrevisto;
  }

  final openingDateText = effectiveDate != null
      ? Formatters.formatDateForHistory(effectiveDate)
      : "Data não disponível";

  final closingDateText = servico.dataFechamento != null
      ? 'Fechado em: ${Formatters.formatDateForHistory(servico.dataFechamento!)}'
      : 'Em aberto';

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 15),
    child: pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Data Abertura: $openingDateText',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    closingDateText,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Técnico: ${servico.nomeTecnico?.trim() ?? ''}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Valor: ${Formatters.formatValuePdf(servico.valor)}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Table(
          border: const pw.TableBorder(
            left: pw.BorderSide(),
            right: pw.BorderSide(),
            bottom: pw.BorderSide(),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    Formatters.formatDescriptionForPDF(servico.descricao),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
