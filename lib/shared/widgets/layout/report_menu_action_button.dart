import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/shared/pdf/reports/report_type.dart';
import 'package:serv_oeste/shared/services/report_service.dart';

class ReportMenuActionButton extends StatelessWidget {
  final Servico servico;
  final Cliente cliente;

  const ReportMenuActionButton({
    super.key,
    required this.servico,
    required this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    final ReportService reportService = context.read<ReportService>();

    return PopupMenuButton<ReportType>(
      tooltip: "Gerar relatórios",
      icon: const Icon(Icons.description_outlined),
      offset: Offset(0, 40),
      onSelected: (type) => reportService.generate(
        type: type,
        servico: servico,
        cliente: cliente
      ),
      itemBuilder: (BuildContext context) => const [
        PopupMenuItem(
          value: ReportType.orcamento,
          child: Text("Gerar Orçamento")
        ),
        PopupMenuItem(
          value: ReportType.recibo,
          child: Text("Gerar Recibo")
        ),
        PopupMenuItem(
          value: ReportType.visitas,
          child: Text("Gerar Relátorio de Visitas")
        ),
      ],
    );
  }
}
