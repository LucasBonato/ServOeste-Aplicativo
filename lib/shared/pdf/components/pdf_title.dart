import 'package:pdf/widgets.dart' as pw;

class PdfTitle extends pw.StatelessWidget {
  final String title;

  PdfTitle(this.title);

  @override
  pw.Widget build(pw.Context context) {
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
