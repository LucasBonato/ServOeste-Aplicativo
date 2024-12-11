import 'package:flutter/material.dart';

class ServicoForm extends ChangeNotifier {
  int? idTecnico;
  ValueNotifier<String> equipamento = ValueNotifier("");
  ValueNotifier<String> marca = ValueNotifier("");
  ValueNotifier<String> filial = ValueNotifier("");
  ValueNotifier<String> nomeTecnico = ValueNotifier("");
  ValueNotifier<String> dataPrevista = ValueNotifier("");
  ValueNotifier<String> horario = ValueNotifier("");
  ValueNotifier<String> descricao = ValueNotifier("");

  void setIdTecnico(int? idTecnico) {
    this.idTecnico = idTecnico;
    notifyListeners();
  }

  void setEquipamento(String? equipamento) {
    this.equipamento.value = equipamento ?? "";
    notifyListeners();
  }

  void setMarca(String? marca) {
    this.marca.value = marca ?? "";
    notifyListeners();
  }

  void setFilial(String? filial) {
    this.filial.value = filial ?? "";
    notifyListeners();
  }

  void setNomeTecnico(String? nomeTecnico) {
    this.nomeTecnico.value = nomeTecnico ?? "";
    notifyListeners();
  }

  void setDataPrevista(String? dataPrevista) {
    this.dataPrevista.value = dataPrevista ?? "";
    notifyListeners();
  }

  void setHorario(String? horario) {
    this.horario.value = horario ?? "";
    notifyListeners();
  }

  void setDescricao(String? descricao) {
    this.descricao.value = descricao ?? "";
    notifyListeners();
  }
}
