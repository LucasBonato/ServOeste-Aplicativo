import 'package:flutter/material.dart';

class FloatingActionButtonRemove extends StatelessWidget {
  final dynamic removeMethod;
  final String tooltip;
  final String content;

  const FloatingActionButtonRemove({
    super.key,
    required this.removeMethod,
    required this.tooltip,
    required this.content,
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
            title: const Text('Confirmar Exclusão'),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:
                    Text('Cancelar', style: TextStyle(color: Colors.grey[800])),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  removeMethod();
                },
                style: TextButton.styleFrom(overlayColor: Colors.red),
                child:
                    const Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
      child: const Icon(Icons.delete, color: Colors.white, size: 36),
    );
  }
}
