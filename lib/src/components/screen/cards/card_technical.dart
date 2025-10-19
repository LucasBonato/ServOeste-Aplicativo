import 'package:flutter/material.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

class CardTechnician extends StatelessWidget {
  final int id;
  final String nome;
  final String sobrenome;
  final String? telefone;
  final String? celular;
  final String status;
  final bool isSelected;
  final bool isSkeleton;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;
  final void Function()? onTap;

  const CardTechnician({
    super.key,
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.status,
    this.telefone,
    this.celular,
    this.isSelected = false,
    this.isSkeleton = false,
    this.onLongPress,
    this.onDoubleTap,
    this.onTap,
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
            onLongPress: isSkeleton ? () {} : onLongPress,
            onDoubleTap: isSkeleton ? () {} : onDoubleTap,
            onTap: isSkeleton ? () {} : onTap,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE9E7E7) : const Color(0xFCFDFDFF),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected ? Colors.black38 : (hovered ? Colors.black38 : const Color(0xFFEAE6E5)),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
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
                          fontSize: constraints.maxWidth * 0.06,
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
                                  fontSize: constraints.maxWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (telefone != null && telefone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 28),
                                child: Text(
                                  "Telefone: ${Formatters.applyPhoneMask(telefone!)}",
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.04,
                                  ),
                                ),
                              ),
                            if (celular != null && celular!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 28),
                                child: Text(
                                  "Celular: ${Formatters.applyCellPhoneMask(celular!)}",
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.04,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.045,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
