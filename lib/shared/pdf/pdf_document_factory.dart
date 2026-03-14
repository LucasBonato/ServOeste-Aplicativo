import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfDocumentFactory {
  static Future<pw.Document> create() async {
    final font = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();
    final italic = await PdfGoogleFonts.robotoItalic();

    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: bold,
        italic: italic,
      ),
    );
  }
}
