import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

class PDFBase {
  static Future<pw.Document> createDocument() async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
        italic: fontItalic,
      ),
    );
  }

  static Future<void> savePdfAutomatically({
    required pw.Document pdf,
    required String fileName,
  }) async {
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: fileName,
      );
    } catch (e) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName,
      );
    }
  }

  static pw.Widget buildHeader(pw.ImageProvider logo) {
    return pw.Row(
      children: [
        pw.Container(
          width: 150,
          child: pw.Image(logo),
        ),
        pw.SizedBox(width: 30),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildAddressLine(
                'OSASCO - R. Virgínia Aurora Rodrigues, 215 - Centro',
                'Telefones: 3602-2122 e 94518-4828 - CNPJ: 11.991.194/0001-50',
              ),
              _buildAddressLine(
                'CARAPICUÍBA - Av. Fernanda, 147 - Centro',
                'Telefones: 3602-2122 e 97315-7863 - CNPJ: 29.683.472/0001-78',
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAddressLine(String address, String contact) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Text(
            address,
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Text(
            contact,
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget buildClientServiceTable(Servico servico, Cliente cliente) {
    final effectiveDate =
        Formatters.extractDateFromDescription(servico.descricao);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        _buildTableRow(
          'Data Atendimento: ${_formatDate(effectiveDate)}',
          'Período: ${_formatHorario(servico.horarioPrevisto)}',
        ),
        _buildTableRow(
          'Cliente: ${cliente.nome ?? ''}',
          'Técnico: ${servico.nomeTecnico ?? ''}',
        ),
        _buildTableRow(
          'Tel. Fixo: ${Formatters.formatPhonePdf(cliente.telefoneFixo, isCell: false)}',
          'Celular: ${Formatters.formatPhonePdf(cliente.telefoneCelular, isCell: true)}',
        ),
        _buildTableRow(
          'Bairro: ${cliente.bairro ?? ''}',
          'Município: ${cliente.municipio ?? ''}',
        ),
        _buildTableRow(
          'Endereço: ${cliente.endereco ?? ''}',
          'Valor: ${Formatters.formatValuePdf(servico.valor)}',
        ),
        _buildTableRow(
          'Equipamento: ${servico.equipamento}',
          'Marca: ${servico.marca}',
        ),
      ],
    );
  }

  static pw.TableRow _buildTableRow(String leftText, String rightText) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            leftText,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            rightText,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime? date) {
    return date != null
        ? Formatters.formatDateForHistory(date)
        : "Não informado.";
  }

  static String _formatHorario(String? horario) {
    return horario != null
        ? Formatters.formatScheduleTime(horario)
        : "Não informado.";
  }

  static pw.Widget buildDescriptionSection(String? descricao) {
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
              child: pw.Text(
                Formatters.formatDescriptionForPDF(descricao),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildTitle(String title) {
    return pw.Center(
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }
}
