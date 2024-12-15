import 'package:flutter/material.dart';
import 'package:serv_oeste/src/util/formatters.dart';

class CardTechnical extends StatelessWidget {
  final int id;
  final String nome;
  final String sobrenome;
  final String? telefone;
  final String? celular;
  final String status;
  final bool isSelected;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;

  const CardTechnical({
    super.key,
    required this.id,
    required this.nome,
    required this.sobrenome,
    this.telefone,
    this.celular,
    required this.status,
    this.isSelected = false,
    this.onLongPress,
    this.onDoubleTap,
  });

  String getCompostName(String sobrenome) {
    List<String> compostName = sobrenome.split(' ');

    if (compostName.isNotEmpty) {
      if (compostName.first.length <= 3 && compostName.length > 1) {
        return compostName[1];
      }
      return compostName.first;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hovered, child) {
          return GestureDetector(
            onLongPress: onLongPress,
            onDoubleTap: onDoubleTap,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE9E7E7)
                    : const Color(0xFCFDFDFF),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isSelected
                      ? Colors.black38
                      : (hovered ? Colors.black38 : const Color(0xFFEAE6E5)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "$id",
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width.clamp(20.0, 22.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            "$nome ${getCompostName(sobrenome)}",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context)
                                  .size
                                  .width
                                  .clamp(16.0, 18.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        if (telefone != null && telefone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text(
                              "Telefone: ${Formatters.applyTelefoneMask(telefone!)}",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context)
                                    .size
                                    .width
                                    .clamp(13.0, 15.0),
                              ),
                            ),
                          ),
                        if (celular != null && celular!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text(
                              "Celular: ${Formatters.applyCelularMask(celular!)}",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context)
                                    .size
                                    .width
                                    .clamp(13.0, 15.0),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      color: status.toLowerCase() == "ativo"
                          ? const Color.fromARGB(255, 4, 80, 16)
                          : status.toLowerCase() == "licenca"
                              ? const Color.fromARGB(255, 16, 6, 102)
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
