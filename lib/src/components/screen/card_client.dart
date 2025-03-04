import 'package:flutter/material.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

class CardClient extends StatelessWidget {
  final String name;
  final String? phoneNumber;
  final String? cellphone;
  final String city;
  final String street;
  final bool isSelected;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;
  final void Function()? onTap;

  const CardClient({
    super.key,
    required this.name,
    this.phoneNumber,
    this.cellphone,
    required this.city,
    required this.street,
    required this.isSelected,
    this.onLongPress,
    this.onDoubleTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isHovered,
      builder: (context, hovered, _) {
        return GestureDetector(
          onLongPress: onLongPress,
          onDoubleTap: onDoubleTap,
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE9E7E7) : const Color(0xFCFDFDFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.black : (hovered ? Colors.black38 : const Color(0xFFEAE6E5)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => isHovered.value = true,
                  onExit: (_) => isHovered.value = false,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (phoneNumber != null && phoneNumber!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(
                              'Telefone: ${Formatters.applyTelefoneMask(phoneNumber!)}',
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                              ),
                            ),
                          ),
                        if (cellphone != null && cellphone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(
                              'Celular: ${Formatters.applyCelularMask(cellphone!)}',
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Text(
                            '$city - SP',
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.045,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 36.0),
                          child: Text(
                            street,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.045,
                            ),
                          ),
                        ),
                      ],
                    ),
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
