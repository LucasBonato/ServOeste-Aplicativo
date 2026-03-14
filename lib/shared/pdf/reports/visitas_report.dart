import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/pdf/layout/service_reporty_layout.dart';
import 'package:serv_oeste/shared/pdf/pdf_document_factory.dart';
import 'package:serv_oeste/shared/pdf/reports/pdf_report.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class VisitasReport extends PdfReport {
  final Servico servico;
  final Cliente cliente;
  final List<Servico> historicoServicos;
  final pw.ImageProvider logo;

  VisitasReport({
    required this.servico,
    required this.cliente,
    required this.historicoServicos,
    required this.logo,
  });

  @override
  String get fileName => "visitas_${servico.id}.pdf";

  @override
  Future<pw.Document> build() async {
    final pw.Document document = await PdfDocumentFactory.create();

    final historicoFiltrado = historicoServicos.where((s) => s.id != servico.id).toList();

    final primeirosServicos = historicoFiltrado.length > 3
        ? historicoFiltrado.sublist(0, 3)
        : historicoFiltrado;

    List<pw.Widget> sections = [];

    if (historicoFiltrado.isEmpty) {
      sections.add(
        pw.Text(
          '*ESTE É O PRIMEIRO SERVIÇO DO CLIENTE PARA ESTE EQUIPAMENTO.',
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      );
    }

    if (primeirosServicos.isNotEmpty) {
      sections.add(_buildHistoricoEquipamento(primeirosServicos));
    }

    if (historicoFiltrado.length > 3) {
      sections.add(
        pw.Text(
          '*Mostrando 3 serviços mais recentes de ${historicoFiltrado.length}',
          style: pw.TextStyle(
            fontSize: 8,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      );
    }

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => ServiceReportLayout.build(
          title: "CHAMADO ATUAL - Nº ${servico.id}",
          servico: servico,
          cliente: cliente,
          logo: logo,
          extraSections: sections,
        ),
      ),
    );

    return document;
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
}
