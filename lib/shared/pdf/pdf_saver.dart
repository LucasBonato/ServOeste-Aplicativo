import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfSaver {
  static Future<void> save({
    required pw.Document pdf,
    required String fileName,
  }) async {
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: fileName,
      );
    } catch (_) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName,
      );
    }
  }
}
