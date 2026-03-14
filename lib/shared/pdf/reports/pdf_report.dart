import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/shared/pdf/pdf_saver.dart';

abstract class PdfReport {
  String get fileName;

  Future<pw.Document> build();

  Future<void> generate() async {
    final doc = await build();
    await PdfSaver.save(pdf: doc, fileName: fileName);
  }
}
