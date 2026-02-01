import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter_request.dart';

class ServicoFilterForm extends ChangeNotifier {
  ValueNotifier<String> equipamento = ValueNotifier("");
  ValueNotifier<String> situacao = ValueNotifier("");
  ValueNotifier<String> garantia = ValueNotifier("");
  ValueNotifier<int?> codigo = ValueNotifier(null);
  ValueNotifier<String> filial = ValueNotifier("");
  ValueNotifier<String> dataAtendimentoPrevistoAntes = ValueNotifier("");
  ValueNotifier<String> dataAtendimentoEfetivoAntes = ValueNotifier("");
  ValueNotifier<String> dataAberturaAntes = ValueNotifier("");
  ValueNotifier<String> periodo = ValueNotifier("");

  void setEquipamento(String? equipamento) {
    this.equipamento.value = equipamento ?? "";
    notifyListeners();
  }

  void setSituacao(String? situacao) {
    this.situacao.value = situacao ?? "";
    notifyListeners();
  }

  void setGarantia(String? garantia) {
    this.garantia.value = garantia ?? "";
    notifyListeners();
  }

  void setCodigo(String codigo) {
    this.codigo.value = codigo.isNotEmpty
      ? int.tryParse(codigo) ?? 0
      : null;
    notifyListeners();
  }

  void setFilial(String? filial) {
    this.filial.value = filial ?? "";
    notifyListeners();
  }

  void setDataAtendimentoPrevistoAntes(String dataAtendimentoPrevistoAntes) {
    if (dataAtendimentoPrevistoAntes.isNotEmpty) {
      final DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(dataAtendimentoPrevistoAntes);
      this.dataAtendimentoPrevistoAntes.value = parsedDate.toString();
      notifyListeners();
    }
  }

  void setDataAtendimentoEfetivoAntes(String dataAtendimentoEfetivoAntes) {
    if (dataAtendimentoEfetivoAntes.isNotEmpty) {
      final DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(dataAtendimentoEfetivoAntes);
      this.dataAtendimentoEfetivoAntes.value = parsedDate.toString();
      notifyListeners();
    }
  }

  void setDataAberturaAntes(String dataAberturaAntes) {
    if (dataAberturaAntes.isNotEmpty) {
      final DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(dataAberturaAntes);
      this.dataAberturaAntes.value = parsedDate.toString();
      notifyListeners();
    }
  }

  void setPeriodo(String? periodo) {
    this.periodo.value = periodo ?? "";
    notifyListeners();
  }

  static ServicoFilterForm fromRequest(ServicoFilterRequest? filterRequest) {
    if (filterRequest == null) return ServicoFilterForm();

    final ServicoFilterForm form = ServicoFilterForm();
    form.equipamento.value = filterRequest.equipamento ?? "";
    form.situacao.value = filterRequest.situacao ?? "";
    form.garantia.value = filterRequest.garantia ?? "";
    form.codigo.value = filterRequest.id;
    form.filial.value = filterRequest.filial ?? "";
    form.dataAtendimentoPrevistoAntes.value = filterRequest.dataAtendimentoPrevistoAntes?.toString() ?? "";
    form.dataAtendimentoEfetivoAntes.value = filterRequest.dataAtendimentoEfetivoAntes?.toString() ?? "";
    form.dataAberturaAntes.value = filterRequest.dataAberturaAntes?.toString() ?? "";
    form.periodo.value = filterRequest.periodo ?? "";
    return form;
  }

  void clear() {
    equipamento.value = "";
    situacao.value = "";
    garantia.value = "";
    codigo.value = null;
    filial.value = "";
    dataAtendimentoPrevistoAntes.value = "";
    dataAtendimentoEfetivoAntes.value = "";
    dataAberturaAntes.value = "";
    periodo.value = "";
  }
}
