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
              final double nameSize = Formatters.getResponsiveFontSize(
                constraints.maxWidth,
                min: 14,
                max: 20,
                factor: 0.05,
              );
              final double phoneSize = Formatters.getResponsiveFontSize(
                constraints.maxWidth,
                min: 12,
                max: 18,
                factor: 0.045,
              );
              final double addressSize = Formatters.getResponsiveFontSize(
                constraints.maxWidth,
                min: 12,
                max: 18,
                factor: 0.045,
              );

              final double paddingLeftSmall = Formatters.getResponsiveFontSize(
                constraints.maxWidth,
                min: 12,
                max: 20,
                factor: 0.02,
              );
              final double paddingLeftMedium = Formatters.getResponsiveFontSize(
                constraints.maxWidth,
                min: 16,
                max: 24,
                factor: 0.026,
              );
              final double paddingLeftLarge = Formatters.getResponsiveFontSize(
                constraints.maxWidth,
                min: 20,
                max: 28,
                factor: 0.03,
              );

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
                    padding: const EdgeInsets.only(
                      right: 8,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: paddingLeftSmall,
                            bottom: 2,
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: nameSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (phoneNumber != null && phoneNumber!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              left: paddingLeftMedium,
                              bottom: 2,
                            ),
                            child: Text(
                              'Telefone: ${Formatters.applyPhoneMask(phoneNumber!)}',
                              style: TextStyle(
                                fontSize: phoneSize,
                              ),
                            ),
                          ),
                        if (cellphone != null && cellphone!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              left: paddingLeftMedium,
                              bottom: 4,
                            ),
                            child: Text(
                              'Celular: ${Formatters.applyCellPhoneMask(cellphone!)}',
                              style: TextStyle(
                                fontSize: phoneSize,
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: paddingLeftMedium,
                            bottom: 2,
                          ),
                          child: Text(
                            '$city - SP',
                            style: TextStyle(
                              fontSize: addressSize,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: paddingLeftLarge),
                          child: Text(
                            street,
                            style: TextStyle(
                              fontSize: addressSize,
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
