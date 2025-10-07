import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/pdfs/pdf_base.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

Future<void> generateChamadoTecnicoPDF({
  required Servico servico,
  required Cliente cliente,
  required List<Servico> historicoEquipamento,
}) async {
  final pdf = await PDFBase.createDocument();
  final logo = await imageFromAssetBundle('assets/servOeste.png');
  final outputFileName = 'relatorioVisitas_${servico.id}.pdf';

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
            PDFBase.buildTitle('CHAMADO ATUAL - Nº ${servico.id}'),
            pw.SizedBox(height: 10),
            _buildServiceInfoSection(servico, cliente),
            pw.SizedBox(height: 10),
            _buildHistoricoSection(historicoEquipamento, servico.id),
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
  final effectiveDate =
      Formatters.extractDateFromDescription(servico.descricao);

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
                    'Data Abertura: ${effectiveDate != null ? Formatters.formatDateForHistory(effectiveDate) : "Não informado."}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    servico.dataFechamento != null
                        ? 'Fechado em: ${Formatters.formatDateForHistory(servico.dataFechamento!)}'
                        : 'Não foi fechado.',
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
                    'Técnico: ${servico.nomeTecnico ?? ''}',
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
