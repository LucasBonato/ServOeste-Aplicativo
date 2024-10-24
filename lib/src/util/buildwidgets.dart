import 'package:flutter/material.dart';
import '../components/dialog_box.dart';

class BuildWidgets {
  static FloatingActionButton buildFabRemove(BuildContext context, dynamic removeMethod) {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      shape: const CircleBorder(eccentricity: 0),
      onPressed: () => DialogUtils.showConfirmationDialog(context, "Deletar itens selecionados?", "", "Sim", "Não", () => removeMethod()),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  static FloatingActionButton buildFabAdd(BuildContext context, Widget page) {
    return FloatingActionButton(
      backgroundColor: null,
      shape: const CircleBorder(eccentricity: 0),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: const Icon(Icons.add),
    );
  }
}