import 'package:flutter/material.dart';

class EntityNotFound extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? textStyle;

  const EntityNotFound({
    super.key,
    required this.message,
    this.icon = Icons.search_off,
    this.iconColor = Colors.grey,
    this.iconSize = 40.0,
    this.textStyle = const TextStyle(fontSize: 18.0, color: Colors.grey),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
