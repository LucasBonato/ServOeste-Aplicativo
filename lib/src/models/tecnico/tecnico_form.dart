import 'package:flutter/material.dart';

class TecnicoForm extends ChangeNotifier {
  int? id;
  ValueNotifier<String> nome = ValueNotifier("");
  ValueNotifier<String> situacao = ValueNotifier("");
  ValueNotifier<String> telefoneCelular = ValueNotifier("");
  ValueNotifier<String> telefoneFixo = ValueNotifier("");
  ValueNotifier<List<int>> conhecimentos = ValueNotifier([]);

  void setId(int id) {
    this.id = id;
  }

  void setNome(String? nome) {
    this.nome.value = nome ?? "";
    notifyListeners();
  }

  void setSituacao(String? situacao) {
    this.situacao.value = situacao ?? "";
    notifyListeners();
  }

  void setTelefoneFixo(String? telefoneFixo) {
    this.telefoneFixo.value = telefoneFixo ?? "";
    notifyListeners();
  }

  void setTelefoneCelular(String? telefoneCelular) {
    if (telefoneCelular!.isNotEmpty) {
      this.telefoneCelular.value = telefoneCelular;
      notifyListeners();
    }
  }

  void addConhecimentos(int conhecimento) {
    if (!conhecimentos.value.contains(conhecimento)) {
      conhecimentos.value.add(conhecimento);
    }
    notifyListeners();
  }

  void removeConhecimentos(int conhecimento) {
    conhecimentos.value
        .removeWhere((especialidade) => especialidade == conhecimento);
    notifyListeners();
  }
}
