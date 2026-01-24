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
                final double idSize = Formatters.getResponsiveFontSize(
                  constraints.maxWidth,
                  min: 16,
                  max: 22,
                  factor: 0.055,
                );
                final double nameSize = Formatters.getResponsiveFontSize(
                  constraints.maxWidth,
                  min: 14,
                  max: 20,
                  factor: 0.05,
                );
                final double phoneSize = Formatters.getResponsiveFontSize(
                  constraints.maxWidth,
                  min: 10,
                  max: 14,
                  factor: 0.045,
                );
                final double statusSize = Formatters.getResponsiveFontSize(
                  constraints.maxWidth,
                  min: 12,
                  max: 16,
                  factor: 0.05,
                );

                final bool isCompactLayout = constraints.maxWidth < 320;

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE9E7E7)
                        : const Color(0xFCFDFDFF),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black38
                          : (hovered
                              ? Colors.black38
                              : const Color(0xFFEAE6E5)),
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
                  child: isCompactLayout
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$id",
                                  style: TextStyle(
                                    fontSize: idSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "$nome ${getCompostName(sobrenome)}",
                                    style: TextStyle(
                                      fontSize: nameSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (telefone != null && telefone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 42),
                                child: Text(
                                  "Telefone: ${Formatters.applyPhoneMask(telefone!)}",
                                  style: TextStyle(fontSize: phoneSize),
                                ),
                              ),
                            if (celular != null && celular!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 42),
                                child: Text(
                                  "Celular: ${Formatters.applyCellPhoneMask(celular!)}",
                                  style: TextStyle(fontSize: phoneSize),
                                ),
                              ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: statusSize,
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "$id",
                              style: TextStyle(
                                fontSize: idSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "$nome ${getCompostName(sobrenome)}",
                                      style: TextStyle(
                                        fontSize: nameSize,
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
                                          fontSize: phoneSize,
                                        ),
                                      ),
                                    ),
                                  if (celular != null && celular!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28),
                                      child: Text(
                                        "Celular: ${Formatters.applyCellPhoneMask(celular!)}",
                                        style: TextStyle(
                                          fontSize: phoneSize,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: statusSize,
                                color: _getStatusColor(status),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "ativo":
        return const Color.fromARGB(255, 4, 80, 16);
      case "licenca":
        return const Color.fromARGB(255, 16, 6, 102);
      default:
        return Colors.red;
    }
  }
}
