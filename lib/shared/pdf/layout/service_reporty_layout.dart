import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/pdf/components/pdf_client_service_table.dart';
import 'package:serv_oeste/shared/pdf/components/pdf_description_section.dart';
import 'package:serv_oeste/shared/pdf/components/pdf_header.dart';
import 'package:serv_oeste/shared/pdf/components/pdf_title.dart';

class ServiceReportLayout {
  static List<pw.Widget> build({
    required String title,
    required Servico servico,
    required Cliente cliente,
    required pw.ImageProvider logo,
    List<pw.Widget> extraSections = const [],
  }) {
    return [
      PdfHeader(logo),
      pw.SizedBox(height: 20),
      PdfTitle(title),
      pw.SizedBox(height: 10),
      PdfClientServiceTable(servico: servico, cliente: cliente),
      PdfDescriptionSection(servico.historico),
      pw.SizedBox(height: 20),
      ...extraSections,
    ];
  }
}
