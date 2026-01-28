import 'package:flutter/material.dart';
import 'package:serv_oeste/shared/models/enums/service_status.dart';
import 'package:serv_oeste/shared/utils/extensions/string_extensions.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class ServicoCard extends StatelessWidget {
  final int codigo;
  final String cliente;
  final String equipamento;
  final String marca;
  final String filial;
  final String status;
  final String? tecnico;
  final String? horario;
  final DateTime? dataPrevista;
  final DateTime? dataEfetiva;
  final DateTime? dataFechamento;
  final DateTime? dataFinalGarantia;
  final bool isSelected;
  final bool isSkeleton;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;
  final void Function()? onTap;

  const ServicoCard({
    super.key,
    required this.codigo,
    required this.cliente,
    required this.equipamento,
    required this.marca,
    required this.filial,
    required this.status,
    this.tecnico,
    this.horario,
    this.dataPrevista,
    this.dataEfetiva,
    this.dataFechamento,
    this.dataFinalGarantia,
    this.isSelected = false,
    this.isSkeleton = false,
    this.onLongPress,
    this.onDoubleTap,
    this.onTap,
  });

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.aguardandoAgendamento:
        return Colors.blue;
      case ServiceStatus.aguardandoAprovacaoCliente:
        return const Color.fromARGB(255, 179, 162, 14);
      case ServiceStatus.aguardandoAtendimento:
        return const Color.fromARGB(255, 247, 203, 59);
      case ServiceStatus.aguardandoClienteRetirar:
        return const Color.fromARGB(255, 219, 170, 8);
      case ServiceStatus.aguardandoOrcamento:
        return Colors.orange;
      case ServiceStatus.cancelado:
        return Colors.red;
      case ServiceStatus.compra:
        return Colors.teal;
      case ServiceStatus.cortesia:
        return Colors.tealAccent;
      case ServiceStatus.garantia:
        return const Color.fromARGB(255, 18, 1, 255);
      case ServiceStatus.naoAprovadoPeloCliente:
        return Colors.redAccent;
      case ServiceStatus.naoRetira3Meses:
        return Colors.deepOrange;
      case ServiceStatus.orcamentoAprovado:
        return Colors.green;
      case ServiceStatus.resolvido:
        return const Color.fromARGB(255, 47, 87, 2);
      case ServiceStatus.semDefeito:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double codigoSize = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 16,
          max: 22,
          factor: 0.06,
        );
        final double clienteSize = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 14,
          max: 20,
          factor: 0.05,
        );
        final double equipamentoSize = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 12,
          max: 18,
          factor: 0.05,
        );
        final double tecnicoSize = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 12,
          max: 18,
          factor: 0.05,
        );
        final double filialSize = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 10,
          max: 16,
          factor: 0.045,
        );
        final double dataSize = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 10,
          max: 16,
          factor: 0.045,
        );
        final double statusSize = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 12,
          max: 18,
          factor: 0.05,
        );

        final double paddingLeftSmall = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 8,
          max: 20,
          factor: 0.05,
        );
        final double paddingLeftMedium = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 12,
          max: 30,
          factor: 0.1,
        );
        final double paddingLeftLarge = Formatters.getResponsiveFontSize(
          constraints.maxWidth,
          min: 15,
          max: 45,
          factor: 0.15,
        );

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: ValueListenableBuilder<bool>(
            valueListenable: isHovered,
            builder: (context, hovered, child) {
              return GestureDetector(
                onLongPress: isSkeleton ? () {} : onLongPress,
                onDoubleTap: isSkeleton ? () {} : onDoubleTap,
                onTap: isSkeleton ? () {} : onTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE9E7E7)
                        : const Color(0xFCFDFDFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : (hovered
                              ? Colors.black38
                              : const Color(0xFFEAE6E5)),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(left: paddingLeftSmall),
                          child: Text(
                            '$codigo',
                            style: TextStyle(
                              fontSize: codigoSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: paddingLeftSmall),
                        child: Text(
                          cliente,
                          style: TextStyle(
                            fontSize: clienteSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(left: paddingLeftMedium),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.5,
                          child: Text(
                            "$equipamento - $marca",
                            style: TextStyle(
                              fontSize: equipamentoSize,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(left: paddingLeftMedium),
                        child: Text(
                          "Técnico - ${(tecnico == null) ? "Não declarado" : tecnico}",
                          style: TextStyle(
                            fontSize: tecnicoSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(left: paddingLeftLarge),
                        child: Text(
                          filial,
                          style: TextStyle(
                            fontSize: filialSize,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (dataPrevista != null && dataEfetiva == null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: paddingLeftLarge,
                          ),
                          child: Text(
                            "Data Prevista: ${Formatters.applyDateMask(dataPrevista!)} - ${Formatters.formatScheduleTime(horario!)}",
                            style: TextStyle(
                              fontSize: dataSize,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      if (dataEfetiva != null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: paddingLeftLarge,
                          ),
                          child: Text(
                            "Data Efetiva: ${Formatters.applyDateMask(dataEfetiva!)} - ${Formatters.formatScheduleTime(horario!)}",
                            style: TextStyle(
                              fontSize: dataSize,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      if (dataFechamento != null)
                        Padding(
                          padding: EdgeInsets.only(
                            top: 3,
                            left: paddingLeftLarge,
                          ),
                          child: Text(
                            "Data Fechamento: ${Formatters.applyDateMask(dataFechamento!)}",
                            style: TextStyle(
                              fontSize: dataSize,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      if (dataFinalGarantia != null)
                        Padding(
                          padding: EdgeInsets.only(
                            top: 3,
                            left: paddingLeftLarge,
                          ),
                          child: Text(
                            "Data Final da Garantia: ${Formatters.applyDateMask(dataFinalGarantia!)}",
                            style: TextStyle(
                              fontSize: dataSize,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: paddingLeftSmall, top: 5),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.45,
                            child: Text(
                              status.convertEnumStatusToString(),
                              style: TextStyle(
                                fontSize: statusSize,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(
                                    Formatters.mapStringStatusToEnumStatus(
                                        status)),
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
