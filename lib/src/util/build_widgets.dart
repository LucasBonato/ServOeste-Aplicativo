import 'package:flutter/material.dart';
import 'dialog_box.dart';

class BuildWidgets {
  static FloatingActionButton buildFabAdd(BuildContext context, String route, dynamic event, {String tooltip = ''}) {
    return FloatingActionButton(
      heroTag: "Add_$route",
      backgroundColor: Colors.blue,
      shape: const CircleBorder(eccentricity: 0),
      elevation: 8,
      tooltip: tooltip,
      onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(route).then((value) => value ?? event()),
      child: const Icon(Icons.add, color: Colors.white, size: 36),
    );
  }

  static FloatingActionButton buildFabRemove(BuildContext context, dynamic removeMethod, {String tooltip = ''}) {
    return FloatingActionButton(
      heroTag: "Remove_$tooltip",
      backgroundColor: Colors.red,
      shape: const CircleBorder(eccentricity: 0),
      elevation: 8,
      tooltip: tooltip,
      onPressed: () => DialogUtils.showConfirmationDialog(
        context,
        "Deletar itens selecionados?",
        "",
        "Sim",
        "Não",
        removeMethod,
      ),
      child: const Icon(Icons.delete, color: Colors.white, size: 36),
    );
  }
}
