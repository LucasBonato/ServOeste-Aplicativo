import 'package:flutter/material.dart';

class CardClient extends StatefulWidget {
  final String nome;
  final String? telefone;
  final String? celular;
  final String cidade;
  final String rua;
  final String numero;
  final bool isSelected;

  const CardClient({
    super.key,
    required this.nome,
    this.telefone,
    this.celular,
    required this.cidade,
    required this.rua,
    required this.numero,
    required this.isSelected,
  });

  @override
  State<CardClient> createState() => _CardClientState();
}

class _CardClientState extends State<CardClient> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click, // Alterar cursor para pointer
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromARGB(255, 207, 211, 211).withOpacity(0.2)
              : const Color(0xFCFDFDFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (widget.isSelected || _isHovered)
                ? Color.fromARGB(255, 70, 71, 71)
                : Colors.transparent,
            width: (widget.isSelected || _isHovered) ? 1 : 1,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nome,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(16.0, 18.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (widget.telefone != null)
              Text(
                widget.telefone!,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width.clamp(14.0, 16.0),
                ),
              ),
            if (widget.celular != null)
              Text(
                widget.celular!,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width.clamp(14.0, 16.0),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              "${widget.cidade} - SP",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(14.0, 16.0),
              ),
            ),
            Text(
              "${widget.rua} - ${widget.numero}",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(14.0, 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
