import 'package:flutter/material.dart';

class CardClient extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String city;
  final String street;
  final bool isSelected;

  const CardClient({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.city,
    required this.street,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.3) : Color(0xFCFDFDFF),
        borderRadius: BorderRadius.circular(12),
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
            name,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width.clamp(16.0, 18.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phoneNumber,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width.clamp(14.0, 16.0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            city,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width.clamp(14.0, 16.0),
            ),
          ),
          Text(
            street,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width.clamp(14.0, 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
