import 'package:flutter/material.dart';
import 'package:serv_oeste/models/tecnico.dart';

import '../../models/cliente.dart';
import '../../widgets/dialog_box.dart';

class Constants {
  static const String baseUri = "http://localhost:8080/api/v1";
  //static const String baseUri = "http://10.0.2.2:8080/api/v1";

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

  static String transformTelefone({Tecnico? tecnico, Cliente? cliente}){
    String telefoneC;
    String telefoneF;
    if(tecnico == null) {
      telefoneC = cliente?.telefoneCelular ?? "";
      telefoneF = cliente?.telefoneFixo ?? "";
    } else {
      telefoneC = tecnico.telefoneCelular ?? "";
      telefoneF = tecnico.telefoneFixo ?? "";
    }
    String telefone = (telefoneC.isNotEmpty) ? telefoneC : telefoneF;
    String telefoneFormatado = "Telefone: (${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
    return telefoneFormatado;
  }
}