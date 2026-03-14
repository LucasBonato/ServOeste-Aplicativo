import 'package:pdf/widgets.dart' as pw;
import 'package:serv_oeste/shared/pdf/components/pdf_address_line.dart';

class PdfHeader extends pw.StatelessWidget {
  final pw.ImageProvider logo;

  PdfHeader(this.logo);

  @override
  pw.Widget build(pw.Context context) {
    return pw.Row(
      children: [
        pw.Container(width: 150, child: pw.Image(logo)),
        pw.SizedBox(width: 30),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfAddressLine(
                address: 'OSASCO - R. Virgínia Aurora Rodrigues, 215 - Centro',
                contact: 'Telefones: 3602-2122 e 94518-4828',
              ),
              PdfAddressLine(
                address: 'CARAPICUÍBA - Av. Fernanda, 147 - Centro',
                contact: 'Telefones: 3602-2122 e 97315-7863',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
