import 'package:flutter/material.dart';

class EntityNotFound extends StatelessWidget {
  final String message;

  const EntityNotFound({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            color: Colors.grey,
            size: 40.0,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 18.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
