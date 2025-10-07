import 'package:flutter/material.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

class CardClient extends StatelessWidget {
  final String name;
  final String? phoneNumber;
  final String? cellphone;
  final String city;
  final String street;
  final bool isSelected;
  final bool isSkeleton;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;
  final void Function()? onTap;

  const CardClient({
    super.key,
    required this.isSelected,
    required this.street,
    required this.name,
    required this.city,
    this.phoneNumber,
    this.onDoubleTap,
    this.onLongPress,
    this.cellphone,
    this.onTap,
    this.isSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isHovered,
      builder: (context, hovered, _) {
        return GestureDetector(
          onLongPress: isSkeleton ? () {} : onLongPress,
          onDoubleTap: isSkeleton ? () {} : onDoubleTap,
          onTap: isSkeleton ? () {} : onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE9E7E7)
                      : const Color(0xFCFDFDFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.black
                        : (hovered ? Colors.black38 : const Color(0xFFEAE6E5)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                              'Telefone: ${Formatters.applyPhoneMask(phoneNumber!)}',
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.045,
                              ),
                            ),
                          ),
                        if (cellphone != null && cellphone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(
                              'Celular: ${Formatters.applyCellPhoneMask(cellphone!)}',
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
