import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class PDFBase {
  static pw.Widget buildClientServiceTable(Servico servico, Cliente cliente) {
    final DateTime? effectiveDate = Formatters.extractDateFromDescription(
      servico.historico,
    );

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
          child: pw.Text(leftText, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(rightText, style: const pw.TextStyle(fontSize: 10)),
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
}
