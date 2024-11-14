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

  static FloatingActionButton buildFabAdd(BuildContext context, String route) {
    return FloatingActionButton(
      backgroundColor: null,
      shape: const CircleBorder(eccentricity: 0),
      onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(route),
      child: const Icon(Icons.add),
    );
  }
}