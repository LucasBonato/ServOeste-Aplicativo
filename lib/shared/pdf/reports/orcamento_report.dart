import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/pdf/layout/service_reporty_layout.dart';
import 'package:serv_oeste/shared/pdf/pdf_document_factory.dart';
import 'package:serv_oeste/shared/pdf/reports/pdf_report.dart';

class OrcamentoReport extends PdfReport {
  final Servico servico;
  final Cliente cliente;
  final pw.ImageProvider logo;

  OrcamentoReport({
    required this.servico,
    required this.cliente,
    required this.logo,
  });

  @override
  String get fileName => "orcamento_${servico.id}.pdf";

  @override
  Future<pw.Document> build() async {
    final pw.Document document = await PdfDocumentFactory.create();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => ServiceReportLayout.build(
          title: "ORÇAMENTO - Nº ${servico.id}",
          servico: servico,
          cliente: cliente,
          logo: logo,
          extraSections: [
            _buildGarantiaTerms(),
            pw.SizedBox(height: 30),
            _buildSignatureField(),
          ],
        )
      )
    );

    return document;
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
}
