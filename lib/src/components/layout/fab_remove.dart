import 'package:flutter/material.dart';

class FloatingActionButtonRemove extends StatelessWidget {
  final dynamic removeMethod;
  final String tooltip;

  const FloatingActionButtonRemove({
    super.key,
    required this.removeMethod,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "Remove_$tooltip",
      backgroundColor: Colors.red,
      shape: const CircleBorder(eccentricity: 0),
      elevation: 8,
      tooltip: tooltip,
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Text("Deletar itens selecionados?", textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                style: const ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF007BFF)),
                    foregroundColor: WidgetStatePropertyAll(Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  removeMethod();
                },
                child: Text("Sim", style: const TextStyle(fontSize: 25)),
              ),
              TextButton(
                style: const ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Não", style: const TextStyle(fontSize: 25)),
              )
            ],
          );
        },
      ),
      child: const Icon(Icons.delete, color: Colors.white, size: 36),
    );
  }
}
