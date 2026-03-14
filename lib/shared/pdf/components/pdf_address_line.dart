import 'package:pdf/widgets.dart' as pw;

class PdfAddressLine extends pw.StatelessWidget {
  final String address;
  final String contact;

  PdfAddressLine({
    required this.address,
    required this.contact,
  });

  @override
  pw.Widget build(pw.Context context) {
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
}
