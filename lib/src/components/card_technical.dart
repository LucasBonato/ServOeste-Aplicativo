import 'package:flutter/material.dart';

class CardTechnical extends StatefulWidget {
  final int id;
  final String name;
  final String phoneNumber;
  final String cellPhoneNumber;
  final String status;
  final bool isSelected;

  const CardTechnical({
    super.key,
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.cellPhoneNumber,
    required this.status,
    this.isSelected = false,
  });

  @override
  State<CardTechnical> createState() => _CardTechnicalState();
}

class _CardTechnicalState extends State<CardTechnical> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromARGB(255, 207, 211, 211).withOpacity(0.2)
              : const Color(0xFCFDFDFF),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: (widget.isSelected || _isHovered)
                ? Color.fromARGB(255, 70, 71, 71)
                : Colors.grey.shade300,
            width: (widget.isSelected || _isHovered) ? 1 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$widget.id",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("Telefone fixo: ${widget.phoneNumber}"),
            Text("Celular: ${widget.cellPhoneNumber}"),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                widget.status,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.status == "Ativo"
                      ? const Color.fromARGB(255, 4, 80, 16)
                      : widget.status == "Licença"
                          ? const Color.fromARGB(255, 25, 6, 199)
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
