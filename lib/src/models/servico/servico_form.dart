import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class ServicoForm extends ChangeNotifier {
  int? id;
  ValueNotifier<String> equipamento = ValueNotifier("");
  ValueNotifier<String> marca = ValueNotifier("");
  ValueNotifier<String> filial = ValueNotifier("");
  ValueNotifier<String> tecnico = ValueNotifier("");
  ValueNotifier<String> dataPrevista = ValueNotifier("");
  ValueNotifier<String> horario = ValueNotifier("");
  ValueNotifier<String> descricao = ValueNotifier("");

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

  void setTecnico(String? tecnico) {
    this.tecnico.value = tecnico ?? "";
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
