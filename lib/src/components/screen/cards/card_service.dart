import 'package:flutter/material.dart';
import 'package:serv_oeste/src/models/enums/service_status.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

class CardService extends StatelessWidget {
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
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;
  final void Function()? onTap;

  const CardService({
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

  String _convertEnumStatusToString(String status) {
    final specialCases = {
      'NAO_RETIRA_3_MESES': 'Não retira há 3 meses',
      'AGUARDANDO_APROVACAO': 'Aguardando aprovação do cliente',
      'AGUARDANDO_ORCAMENTO': 'Aguardando orçamento',
      'ORCAMENTO_APROVADO': 'Orçamento aprovado',
      'NAO_APROVADO': 'Não aprovado pelo cliente',
    };

    if (specialCases.containsKey(status)) {
      return specialCases[status]!;
    }

    String convertedStatus = "${status[0]}${status.substring(1).replaceAll("_", " ").toLowerCase()}";
    return convertedStatus;
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, child) {
            return GestureDetector(
              onLongPress: onLongPress,
              onDoubleTap: onDoubleTap,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: 200,
                  maxWidth: constraints.maxWidth,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE9E7E7) : const Color(0xFCFDFDFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.black : (hovered ? Colors.black38 : const Color(0xFFEAE6E5)),
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(left: constraints.maxWidth * 0.05, bottom: constraints.maxWidth * 0.05),
                            child: Text(
                              '$codigo',
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.065,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: constraints.maxWidth * 0.05),
                          child: Text(
                            cliente,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: constraints.maxWidth * 0.1),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.5,
                            child: Text(
                              "$equipamento - $marca",
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.05,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: constraints.maxWidth * 0.1, top: constraints.maxWidth * 0.035),
                          child: Text(
                            "Técnico - ${(tecnico == null) ? "Não declarado" : tecnico}",
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(left: constraints.maxWidth * 0.15),
                          child: Text(
                            filial,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.045,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (dataPrevista != null && dataEfetiva == null)
                          Padding(
                            padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.15,
                            ),
                            child: Text(
                              "Data Prevista: ${Formatters.applyDateMask(dataPrevista!)} - ${Formatters.formatHorario(horario!)}",
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (dataEfetiva != null)
                          Padding(
                            padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.15,
                            ),
                            child: Text(
                              "Data Efetiva: ${Formatters.applyDateMask(dataEfetiva!)} - ${Formatters.formatHorario(horario!)}",
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (dataFechamento != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: 3,
                              left: constraints.maxWidth * 0.15,
                            ),
                            child: Text(
                              "Data Fechamento: ${Formatters.applyDateMask(dataFechamento!)}",
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (dataFinalGarantia != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: 3,
                              left: constraints.maxWidth * 0.15,
                            ),
                            child: Text(
                              "Data Final da Garantia: ${Formatters.applyDateMask(dataFinalGarantia!)}",
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(left: constraints.maxWidth * 0.05, top: constraints.maxWidth * 0.05),
                            child: SizedBox(
                              width: constraints.maxWidth * 0.45,
                              child: Text(
                                _convertEnumStatusToString(status),
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(Formatters.mapStringStatusToEnumStatus(status)),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
