import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class PdfClientServiceTable extends pw.StatelessWidget {
  final Servico servico;
  final Cliente cliente;

  PdfClientServiceTable({required this.servico, required this.cliente});

  @override
  pw.Widget build(pw.Context context) {
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
        _row(
          'Data Atendimento: ${_formatDate(effectiveDate)}',
          'Período: ${_formatHorario(servico.horarioPrevisto)}',
        ),
        _row(
          'Cliente: ${cliente.nome ?? ''}',
          'Técnico: ${servico.nomeTecnico ?? ''}',
        ),
        _row(
          'Tel. Fixo: ${Formatters.formatPhonePdf(cliente.telefoneFixo, isCell: false)}',
          'Celular: ${Formatters.formatPhonePdf(cliente.telefoneCelular, isCell: true)}',
        ),
        _row(
          'Bairro: ${cliente.bairro ?? ''}',
          'Município: ${cliente.municipio ?? ''}',
        ),
        _row(
          'Endereço: ${cliente.endereco ?? ''}',
          'Valor: ${Formatters.formatValuePdf(servico.valor)}',
        ),
        _row('Equipamento: ${servico.equipamento}', 'Marca: ${servico.marca}'),
      ],
    );
  }

  pw.TableRow _row(String left, String right) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(left, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(right, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? Formatters.formatDateForHistory(date)
        : "Não informado.";
  }

  String _formatHorario(String? horario) {
    return horario != null
        ? Formatters.formatScheduleTime(horario)
        : "Não informado.";
  }
}
