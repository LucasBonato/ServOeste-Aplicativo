import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

Future<void> generateOrcamentoPDF({
  required Servico servico,
  required Cliente cliente,
  required BuildContext context,
}) async {
  final pdf = pw.Document();
  final logo = await imageFromAssetBundle('assets/servOeste.png');
  final outputFileName = 'orcamento_${servico.id}.pdf';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(logo),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'ORÇAMENTO - Nº ${servico.id}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            _buildAtendimentoInfo(servico, cliente),
            pw.SizedBox(height: 20),
            _buildGarantiaTerms(),
            pw.SizedBox(height: 30),
            _buildSignatureField(),
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
        width: 100,
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

pw.Widget _buildAtendimentoInfo(Servico servico, Cliente cliente) {
  return pw.Column(
    children: [
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                    'Data Atendimento: ${Formatters.applyDateMask(servico.dataAtendimentoEfetivo!)}'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                    'Período: ${Formatters.formatHorario(servico.horarioPrevisto!)}'),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Cliente: ${cliente.nome ?? ''}'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Técnico: ${servico.nomeTecnico ?? ''}'),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Tel. Fixo: ${cliente.telefoneFixo != null && cliente.telefoneFixo!.isNotEmpty ? Formatters.applyTelefoneMask(cliente.telefoneFixo!) : '(  )       -    '}',
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Celular: ${cliente.telefoneCelular != null && cliente.telefoneCelular!.isNotEmpty ? Formatters.applyCelularMask(cliente.telefoneCelular!) : '(  )         -    '}',
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Bairro: ${cliente.bairro ?? ''}'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Município: ${cliente.municipio ?? ''}'),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Endereço: ${cliente.endereco ?? ''}'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                    'Valor: ${servico.valor == null || servico.valor == 0 ? 'Não informado' : Formatters.formatToCurrency(servico.valor!)}'),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Equipamento: ${servico.equipamento}'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Marca: ${servico.marca}'),
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

pw.Widget _buildGarantiaTerms() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Text(
          'GARANTIA DE 3 (TRÊS) MESES.',
          style: pw.TextStyle(fontSize: 12),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Text(
          'Solicitamos retirar o APARELHO em até 30 dias no MÁXIMO.',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Comprometo-me a RETIRAR o aparelho em até 90 DIAS. Após esse prazo, AUTORIZO a SERV-OESTE a DESFAZER-SE do mesmo.',
          style: pw.TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}

pw.Widget _buildSignatureField() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Divider(),
      pw.Text('Assinatura'),
    ],
  );
}
