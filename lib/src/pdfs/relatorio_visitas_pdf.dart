import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

Future<void> generateChamadoTecnicoPDF({
  required Servico servico,
  required Cliente cliente,
  required List<Servico> historicoEquipamento
}) async {
  final pdf = pw.Document();
  final logo = await imageFromAssetBundle('assets/servOeste.png');
  final outputFileName = 'relatorioVisitas_${servico.id}.pdf';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(logo),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'CHAMADO ATUAL - Nº ${servico.id}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            _buildServiceInfoTable(servico, cliente),
            pw.SizedBox(height: 10),
            if (historicoEquipamento.length <= 1)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10),
                child: pw.Text(
                  '*ESTE É O PRIMEIRO SERVIÇO DO CLIENTE PARA ESTE EQUIPAMENTO.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            if (historicoEquipamento.length > 1)
              _buildHistoricoEquipamento(historicoEquipamento),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: outputFileName,
  );
}

pw.Widget _buildHeader(pw.ImageProvider logo) {
  return pw.Row(
    children: [
      pw.Container(
        width: 150,
        child: pw.Image(logo),
      ),
      pw.SizedBox(width: 30),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                'OSASCO - R. Virgínia Aurora Rodrigues, 215 - Centro',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                'Telefones: 3602-2122 e 94518-4828 - CNPJ: 11.991.194/0001-50',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                'CARAPICUÍBA - Av. Fernanda, 147 - Centro',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                'Telefones: 3602-2122 e 97315-7863 - CNPJ: 29.683.472/0001-78',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildServiceInfoTable(Servico servico, Cliente cliente) {
  return pw.Column(
    children: [
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(1),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Data Atendimento: ${Formatters.applyDateMask(servico.dataAtendimentoEfetivo!)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Período: ${Formatters.formatHorario(servico.horarioPrevisto!)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Cliente: ${cliente.nome ?? ''}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Técnico: ${servico.nomeTecnico ?? ''}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Tel. Fixo: ${Formatters.formatPhonePdf(cliente.telefoneFixo, isCell: false)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Celular: ${Formatters.formatPhonePdf(cliente.telefoneCelular, isCell: true)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Bairro: ${cliente.bairro ?? ''}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Município: ${cliente.municipio ?? ''}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Endereço: ${cliente.endereco ?? ''}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Valor: ${Formatters.formatValuePdf(servico.valor)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Equipamento: ${servico.equipamento}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Marca: ${servico.marca}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
      pw.Table(
        border: const pw.TableBorder(
          left: pw.BorderSide(),
          right: pw.BorderSide(),
          bottom: pw.BorderSide(),
        ),
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  servico.descricao ?? 'Sem descrição',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildHistoricoEquipamento(List<Servico> historico) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 15),
      pw.Text(
        'HISTÓRICO DESTE EQUIPAMENTO',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(1),
        },
        children: [
          for (var servico in historico) ..._buildHistoricoRow(servico),
        ],
      ),
    ],
  );
}

List<pw.TableRow> _buildHistoricoRow(Servico servico) {
  return [
    pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            'Data Abertura: ${Formatters.applyDateMask(servico.dataAtendimentoEfetivo!)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            servico.dataFechamento != null
                ? 'Fechado em: ${Formatters.applyDateMask(servico.dataFechamento!)}'
                : 'Não foi fechado.',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
    pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            'Técnico: ${servico.nomeTecnico ?? ''}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            'Valor: ${Formatters.formatToCurrency(servico.valor ?? 0)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
    pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            servico.descricao ?? 'Sem descrição',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Container(),
      ],
    ),
    pw.TableRow(
      children: [
        pw.SizedBox(height: 8),
        pw.SizedBox(height: 8),
      ],
    ),
  ];
}
