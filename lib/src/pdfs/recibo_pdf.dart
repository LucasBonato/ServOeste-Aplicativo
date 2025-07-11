import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

Future<void> generateReciboPDF({
  required Servico servico,
  required Cliente cliente,
  required BuildContext context,
}) async {
  final pdf = pw.Document();
  final logo = await imageFromAssetBundle('assets/servOeste.png');
  final outputFileName = 'recibo_${servico.id}.pdf';

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
                'RECIBO - Nº ${servico.id}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            _buildAtendimentoInfo(servico, cliente),
            _buildGarantiaFields(servico),
            _buildPagamentoField(servico),
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
                  'Data Atendimento: ${Formatters.formatDatePdf(servico.dataAtendimentoEfetivo)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Período: ${Formatters.formatHorario(servico.horarioPrevisto!)}',
                  style: pw.TextStyle(fontSize: 10),
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
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Técnico: ${servico.nomeTecnico ?? ''}',
                  style: pw.TextStyle(fontSize: 10),
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
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Celular: ${Formatters.formatPhonePdf(cliente.telefoneCelular, isCell: true)}',
                  style: pw.TextStyle(fontSize: 10),
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
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Município: ${cliente.municipio ?? ''}',
                  style: pw.TextStyle(fontSize: 10),
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
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Valor: ${Formatters.formatValuePdf(servico.valor)}',
                  style: pw.TextStyle(fontSize: 10),
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
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Marca: ${servico.marca}',
                  style: pw.TextStyle(fontSize: 10),
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
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildGarantiaFields(Servico servico) {
  return pw.Table(
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
              'Início garantia: ${Formatters.formatDatePdf(servico.dataInicioGarantia)}',
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Fim garantia: ${Formatters.formatDatePdf(servico.dataFimGarantia)}',
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildPagamentoField(Servico servico) {
  return pw.Table(
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
            child:
                pw.Text('Forma de pagamento: ${servico.formaPagamento ?? ''}'),
          ),
        ],
      ),
    ],
  );
}
