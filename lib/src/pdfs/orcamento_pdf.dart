import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/pdfs/pdf_base.dart';

Future<void> generateOrcamentoPDF({
  required Servico servico,
  required Cliente cliente,
}) async {
  final pdf = await PDFBase.createDocument();
  final logo = await imageFromAssetBundle('assets/servOeste.png');
  final outputFileName = 'orcamento_${servico.id}.pdf';

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
            PDFBase.buildTitle('ORÇAMENTO - Nº ${servico.id}'),
            pw.SizedBox(height: 10),
            _buildAtendimentoInfo(servico, cliente),
            pw.SizedBox(height: 20),
            _buildGarantiaTerms(),
            pw.SizedBox(height: 30),
            _buildSignatureField(),
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

pw.Widget _buildGarantiaTerms() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Text(
          'GARANTIA DE 3 (TRÊS) MESES.',
          style: pw.TextStyle(fontSize: 12),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Text(
          'Solicitamos retirar o APARELHO em até 30 dias no MÁXIMO.',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Comprometo-me a RETIRAR o aparelho em até 90 DIAS. Após esse prazo, AUTORIZO a SERV-OESTE a DESFAZER-SE do mesmo.',
          style: pw.TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}

pw.Widget _buildSignatureField() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Divider(),
      pw.Text('Assinatura'),
    ],
  );
}
