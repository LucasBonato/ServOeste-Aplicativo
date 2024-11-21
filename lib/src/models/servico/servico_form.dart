
import 'package:flutter/cupertino.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class ServicoForm extends ChangeNotifier {
  ValueNotifier<String> equipamento = ValueNotifier("");
  ValueNotifier<String> marca = ValueNotifier("");
  ValueNotifier<String> filial = ValueNotifier("");
  ValueNotifier<String> dataAtendimentoPrevisto = ValueNotifier("");
  ValueNotifier<String> horarioPrevisto = ValueNotifier("");
  ValueNotifier<String> descricao = ValueNotifier("");
  ValueNotifier<String> nomeTecnico = ValueNotifier("");
  ValueNotifier<int?> idTecnico = ValueNotifier(null);

  void setEquipamento(String? equipamento) {
    if(equipamento != null && equipamento.isNotEmpty) {
      this.equipamento.value = Constants.equipamentos.contains(equipamento) ? equipamento : "Outros";
      notifyListeners();
    } else {
      this.equipamento.value = "";
    }
  }

  void setMarca(String? marca) {
    this.marca.value = marca?? "";
    notifyListeners();
  }

  void setFilial(String? filial) {
    this.filial.value = filial?? "";
    notifyListeners();
  }

  void setDataAtendimentoPrevisto(String? dataAtendimentoPrevisto) {
    this.dataAtendimentoPrevisto.value = dataAtendimentoPrevisto?? "";
    notifyListeners();
  }

  void setHorarioPrevisto(String? horarioPrevisto) {
    this.horarioPrevisto.value = horarioPrevisto?? "";
    notifyListeners();
  }

  void setDescricao(String? descricao) {
    this.descricao.value = descricao?? "";
    notifyListeners();
  }

  void setNomeTecnico(String? nomeTecnico) {
    this.nomeTecnico.value = nomeTecnico?? "";
    notifyListeners();
  }

  void setIdTecnico(int? idTecnico) {
    this.idTecnico.value = idTecnico;
    notifyListeners();
  }

  bool isRequiredFieldsFilled() {
    return (
        idTecnico.value != null &&
        equipamento.value.isNotEmpty &&
        descricao.value.isNotEmpty
      );
  }
}

class ServicoValidator extends LucidValidator<ServicoForm> {
  final Map<String, String> externalErrors = {};
  final String equipamentoKey = "equipamento";
  final String marcaKey = "marca";
  final String filialKey = "filial";
  final String dataAtendimentoPrevistoKey = "dataAtendimentoPrevisto";
  final String horarioPrevistoKey = "horarioPrevisto";
  final String descricaoKey = "descricao";
  final String nomeTecnicoKey = "nomeTecnico";

  ServicoValidator() {
    ruleFor((servico) => servico.equipamento.value, key: equipamentoKey)
        .isNotNull();
  }

  void applyBackendError(ErrorEntity errorEntity) {
    switch (errorEntity.id) {
    }
  }

  void cleanExternalErrors() {
    externalErrors.clear();
  }

  void _addError(String key, String message) {
    externalErrors[key] = message;
  }

  void _addListError(List<String> keys, String message) {
    for (String key in keys) {
      externalErrors[key] = message;
    }
  }
}

extension on LucidValidationBuilder<String, dynamic> {
  LucidValidationBuilder<String, dynamic> customValidExternalErrors(Map<String, String> externalErrors, String code) {
    ValidationException? callback(value, entity) {
      if(externalErrors[code] == null) {
        return null;
      }
      return ValidationException(
          message: externalErrors[code]!,
          code: code
      );
    }

    return use(callback);
  }
}