import 'package:flutter/material.dart';

class CardService extends StatelessWidget {
  final String cliente;
  final String equipamento;
  final String marca;
  final String tecnico;
  final String local;
  final String status;
  final DateTime data;
  final bool isSelected;

  const CardService({
    super.key,
    required this.cliente,
    required this.equipamento,
    required this.marca,
    required this.tecnico,
    required this.local,
    required this.data,
    required this.status,
    this.isSelected = false,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case "Aguardando Agendamento":
        return Colors.blue;
      case "Aguardando Aprovação do Cliente":
        return const Color.fromARGB(255, 179, 162, 14);
      case "Aguardando Atendimento":
        return const Color.fromARGB(255, 247, 203, 59);
      case "Aguardando Cliente Retirar":
        return const Color.fromARGB(255, 219, 170, 8);
      case "Aguardando Orçamento":
        return Colors.orange;
      case "Cancelado":
        return Colors.red;
      case "Compra":
        return Colors.teal;
      case "Cortesia":
        return Colors.tealAccent;
      case "Garantia":
        return const Color.fromARGB(255, 18, 1, 255);
      case "Não Aprovado pelo Cliente":
        return Colors.redAccent;
      case "Não Retira há 3 Meses":
        return Colors.deepOrange;
      case "Orçamento Aprovado":
        return Colors.green;
      case "Resolvido":
        return const Color.fromARGB(255, 47, 87, 2);
      case "Sem Defeito":
        return Colors.blueAccent;
      default:
        return Colors.black;
    }
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
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100,
                maxHeight: 200,
                maxWidth: constraints.maxWidth,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE9E7E7)
                      : const Color(0xFCFDFDFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? Colors.black38
                        : (hovered ? Colors.black38 : const Color(0xFFEAE6E5)),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.05),
                          child: Text(
                            cliente,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding:
                              EdgeInsets.only(left: constraints.maxWidth * 0.1),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.5,
                            child: Text(
                              "$equipamento - $marca",
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.1,
                              top: constraints.maxWidth * 0.035),
                          child: Text(
                            "Técnico - $tecnico",
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.15),
                          child: Text(
                            local,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.04,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                            left: constraints.maxWidth * 0.15,
                          ),
                          child: Text(
                            "${data.day}/${data.month}/${data.year}",
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.04,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.4,
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(status),
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
      ),
    );
  }
}
