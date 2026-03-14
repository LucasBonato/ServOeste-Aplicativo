import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/pdf/layout/service_reporty_layout.dart';
import 'package:serv_oeste/shared/pdf/pdf_document_factory.dart';
import 'package:serv_oeste/shared/pdf/reports/pdf_report.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class ReciboReport extends PdfReport {
  final Servico servico;
  final Cliente cliente;
  final pw.ImageProvider logo;

  ReciboReport({
    required this.servico,
    required this.cliente,
    required this.logo,
  });

  @override
  String get fileName => "recibo_${servico.id}.pdf";

  @override
  Future<pw.Document> build() async {
    final pw.Document document = await PdfDocumentFactory.create();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => ServiceReportLayout.build(
          title: "RECIBO - Nº ${servico.id}",
          servico: servico,
          cliente: cliente,
          logo: logo,
          extraSections: [
            _buildGarantiaFields(),
            _buildPagamentoField(),
          ],
        )
      )
    );

    return document;
  }

  pw.Widget _buildGarantiaFields() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Início garantia: ${Formatters.formatDatePdf(servico.dataInicioGarantia)}',
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Fim garantia: ${Formatters.formatDatePdf(servico.dataFimGarantia)}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPagamentoField() {
    return pw.Table(
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
              child:
              pw.Text('Forma de pagamento: ${servico.formaPagamento ?? ''}'),
            ),
          ],
        ),
      ],
    );
  }
}
