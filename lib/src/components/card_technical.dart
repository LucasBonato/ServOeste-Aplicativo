import 'package:flutter/material.dart';

class CardTechnical extends StatelessWidget {
  final int id;
  final String name;
  final String? phoneNumber;
  final String? cellPhoneNumber;
  final String status;
  final bool isSelected;

  const CardTechnical({
    super.key,
    required this.id,
    required this.name,
    this.phoneNumber,
    this.cellPhoneNumber,
    required this.status,
    this.isSelected = false,
  });

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
          return Container(
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
                width: isSelected ? 1.5 : 1,
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
                        padding: const EdgeInsets.only(left: 28),
                        child: Text(
                          name,
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
                      if (phoneNumber != null && phoneNumber!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text(
                            "Telefone fixo: $phoneNumber",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context)
                                  .size
                                  .width
                                  .clamp(13.0, 15.0),
                            ),
                          ),
                        ),
                      if (cellPhoneNumber != null &&
                          cellPhoneNumber!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text(
                            "Celular: $cellPhoneNumber",
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
                        : status.toLowerCase() == "licença"
                            ? const Color.fromARGB(255, 25, 6, 199)
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
  }
}
