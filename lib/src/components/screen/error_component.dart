import 'package:flutter/material.dart';

class ErrorComponent extends StatelessWidget {
  const ErrorComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.not_interested, size: 30),
        SizedBox(height: 16),
        Text("Aconteceu um erro!!"),
      ],
    );
  }
}
