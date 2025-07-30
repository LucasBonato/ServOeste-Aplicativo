import 'package:flutter/material.dart';

class FloatingActionButtonAdd extends StatelessWidget {
  final String route;
  final dynamic event;
  final String tooltip;

  const FloatingActionButtonAdd({
    super.key,
    required this.route,
    required this.event,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "Add_$route",
      backgroundColor: Colors.blue,
      shape: const CircleBorder(eccentricity: 0),
      elevation: 8,
      tooltip: tooltip,
      onPressed: () => Navigator.of(context, rootNavigator: true)
          .pushNamed(route)
          .then((value) {
            if (value == true) {
              event();
            }
          }),
      child: const Icon(Icons.add, color: Colors.white, size: 36),
    );
  }
}
