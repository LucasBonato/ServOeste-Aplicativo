import 'package:flutter/material.dart';

class ServicoForm extends ChangeNotifier {
  int? id;
  ValueNotifier<int?> idCliente = ValueNotifier(null);
  ValueNotifier<int?> idTecnico = ValueNotifier(null);
  ValueNotifier<String> equipamento = ValueNotifier("");
  ValueNotifier<String> marca = ValueNotifier("");
  ValueNotifier<String> filial = ValueNotifier("");
  ValueNotifier<String> nomeCliente = ValueNotifier("");
  ValueNotifier<String> nomeTecnico = ValueNotifier("");
  ValueNotifier<String> dataPrevista = ValueNotifier("");
  ValueNotifier<String> horario = ValueNotifier("");
  ValueNotifier<String> descricao = ValueNotifier("");
  ValueNotifier<String> garantia = ValueNotifier("");
  ValueNotifier<String> situacao = ValueNotifier("");
  ValueNotifier<String> dataAtendimentoPrevisto = ValueNotifier("");
  ValueNotifier<String> dataAtendimentoEfetivo = ValueNotifier("");
  ValueNotifier<String> dataAtendimentoAbertura = ValueNotifier("");

  void setId(int? id) {
    this.id = id;
  }

  void setIdCliente(int? idCliente) {
    this.idCliente.value = idCliente;
    notifyListeners();
  }

  void setIdTecnico(int? idTecnico) {
    this.idTecnico.value = idTecnico;
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

  void setNomeCliente(String? nomeCliente) {
    this.nomeCliente.value = nomeCliente ?? "";
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

  void setGarantia(String? garantia) {
    this.garantia.value = garantia ?? "";
    notifyListeners();
  }

  void setSituacao(String? situacao) {
    this.situacao.value = situacao ?? "";
    notifyListeners();
  }

  void setDataAtendimentoPrevisto(String? dataAtendimentoPrevisto) {
    this.dataAtendimentoPrevisto.value = dataAtendimentoPrevisto ?? "";
    notifyListeners();
  }

  void setDataAtendimentoEfetivo(String? dataAtendimentoEfetivo) {
    this.dataAtendimentoEfetivo.value = dataAtendimentoEfetivo ?? "";
    notifyListeners();
  }

  void setDataAtendimentoAbertura(String? dataAtendimentoAbertura) {
    this.dataAtendimentoAbertura.value = dataAtendimentoAbertura ?? "";
    notifyListeners();
  }
}
