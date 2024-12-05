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

class ServicoValidator extends LucidValidator<ServicoForm> {
  final Map<String, String> externalErrors = {};
  final String equipamentoKey = "equipamento";
  final String marcaKey = "marca";
  final String filialKey = "filial";
  final String tecnicoKey = "tecnico";
  final String dataPrevistaKey = "dataPrevista";
  final String horarioKey = "horario";
  final String descricaoKey = "descricao";

  ServicoValidator() {
    ruleFor((servico) => servico.equipamento.value, key: equipamentoKey).must(
      (equipamento) => equipamento.isNotEmpty,
      "O equipamento é obrigatório!",
      equipamentoKey,
    );

    ruleFor((servico) => servico.marca.value, key: marcaKey).must(
      (marca) => marca.isNotEmpty,
      "A marca é obrigatória!",
      marcaKey,
    );

    ruleFor((servico) => servico.filial.value, key: filialKey).must(
      (filial) => filial.isNotEmpty,
      "A filial é obrigatória!",
      filialKey,
    );

    ruleFor((servico) => servico.tecnico.value, key: tecnicoKey).must(
      (tecnico) => tecnico.isNotEmpty,
      "O nome do técnico é obrigatório!",
      tecnicoKey,
    );

    ruleFor((servico) => servico.dataPrevista.value, key: dataPrevistaKey).must(
      (data) => _validateDate(data),
      "A data é inválida!",
      dataPrevistaKey,
    );

    ruleFor((servico) => servico.horario.value, key: horarioKey).must(
      (horario) => horario.isNotEmpty,
      "O horário é obrigatório!",
      horarioKey,
    );

    ruleFor((servico) => servico.descricao.value, key: descricaoKey)
        .must(
          (descricao) => descricao.isNotEmpty,
          "A descrição é obrigatória!",
          descricaoKey,
        )
        .must(
          (descricao) => descricao.length >= 10,
          "A descrição deve ter pelo menos 10 caracteres!",
          descricaoKey,
        )
        .must(
          (descricao) => descricao.trim().split(RegExp(r'\s+')).length >= 3,
          "A descrição deve conter pelo menos 3 palavras!",
          descricaoKey,
        );
  }

  void applyBackendError(ErrorEntity errorEntity) {
    switch (errorEntity.id) {
      case 1:
        _addError(equipamentoKey, errorEntity.errorMessage);
        break;
      case 2:
        _addError(marcaKey, errorEntity.errorMessage);
        break;
      case 3:
        _addError(filialKey, errorEntity.errorMessage);
        break;
      case 4:
        _addError(tecnicoKey, errorEntity.errorMessage);
        break;
      case 5:
        _addError(dataPrevistaKey, errorEntity.errorMessage);
        break;
      case 6:
        _addError(horarioKey, errorEntity.errorMessage);
        break;
      case 7:
        _addError(descricaoKey, errorEntity.errorMessage);
        break;
    }
  }

  void cleanExternalErrors() {
    externalErrors.clear();
  }

  bool _validateDate(String? date) {
    if (date == null || date.isEmpty) return false;
    final regex = RegExp(r"^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$");
    return regex.hasMatch(date);
  }

  void _addError(String key, String message) {
    externalErrors[key] = message;
  }
}
