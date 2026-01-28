import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'pdf_base.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

Future<void> generateReciboPDF({
  required Servico servico,
  required Cliente cliente,
}) async {
  final pdf = await PDFBase.createDocument();
  final logo = await imageFromAssetBundle('assets/servOeste.png');
  final outputFileName = 'recibo_${servico.id}.pdf';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            PDFBase.buildHeader(logo),
            pw.SizedBox(height: 20),
            PDFBase.buildTitle('RECIBO - Nº ${servico.id}'),
            pw.SizedBox(height: 10),
            _buildAtendimentoInfo(servico, cliente),
            _buildGarantiaFields(servico),
            _buildPagamentoField(servico),
          ],
        );
      },
    ),
  );

  await PDFBase.savePdfAutomatically(
    pdf: pdf,
    fileName: outputFileName,
  );
}

pw.Widget _buildAtendimentoInfo(Servico servico, Cliente cliente) {
  return pw.Column(
    children: [
      PDFBase.buildClientServiceTable(servico, cliente),
      PDFBase.buildDescriptionSection(servico.descricao),
    ],
  );
}

pw.Widget _buildGarantiaFields(Servico servico) {
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

pw.Widget _buildPagamentoField(Servico servico) {
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
            child: pw.Text('Forma de pagamento: ${servico.formaPagamento ?? ''}'),
          ),
        ],
      ),
    ],
  );
}
