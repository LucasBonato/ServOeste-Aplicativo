import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'images/servOeste.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}