import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class PdfDescriptionSection extends pw.StatelessWidget {
  final String? description;

  PdfDescriptionSection(this.description);

  @override
  pw.Widget build(pw.Context context) {
    final List<Map<String, String>> entries = Formatters.parseServiceHistory(description ?? '');

    if (entries.isEmpty) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(),
            right: pw.BorderSide(),
            bottom: pw.BorderSide(),
          ),
        ),
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          'Sem descrição',
          style: const pw.TextStyle(fontSize: 10),
        ),
      );
    }

    return _buildContainer(entries);
  }

  pw.Widget _buildContainer(List<Map<String, String>> entries) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: entries.asMap().entries.map((e) {
        final index = e.key;
        final entry = e.value;

        final isLast = index == entries.length - 1;

        final date = Formatters.formatDateForHistory(entry['data']);

        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(),
              right: pw.BorderSide(),
              bottom: pw.BorderSide(style: isLast ? pw.BorderStyle.solid : pw.BorderStyle.none),
            ),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '$date - ${entry['situacao']}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if ((entry['descricao'] ?? '').isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    entry['descricao']!,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
