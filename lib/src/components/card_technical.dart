import 'package:flutter/material.dart';

class CardTechnical extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Color(0xFCFDFDFF),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
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
            "$id",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Telefone fixo: $phoneNumber"),
          Text("Celular: $cellPhoneNumber"),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14,
                color: status == "Ativo"
                    ? const Color.fromARGB(255, 4, 80, 16)
                    : status == "Licença"
                        ? const Color.fromARGB(255, 25, 6, 199)
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
