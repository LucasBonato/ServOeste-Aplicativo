import 'package:flutter/material.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class CardClient extends StatelessWidget {
  final String name;
  final String? phoneNumber;
  final String? cellphone;
  final String city;
  final String street;
  final bool isSelected;
  final void Function()? onTap;

  const CardClient({
    super.key,
    required this.name,
    this.phoneNumber,
    this.onTap,
    this.cellphone,
    required this.city,
    required this.street,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, child) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE9E7E7)
                    : const Color(0xFCFDFDFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.black
                      : (hovered ? Colors.black38 : Color(0xFFEAE6E5)),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width.clamp(16.0, 18.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (phoneNumber != null && phoneNumber!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Telefone: ${Constants.applyTelefoneMask(phoneNumber!)}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context)
                              .size
                              .width
                              .clamp(13.0, 15.0),
                        ),
                      ),
                    ),
                  if (cellphone != null && cellphone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Celular: ${Constants.applyTelefoneMask(cellphone!)}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context)
                              .size
                              .width
                              .clamp(13.0, 15.0),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '$city - SP',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width.clamp(13.0, 15.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      street,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width.clamp(13.0, 15.0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
