import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class TecnicoForm extends ChangeNotifier {
  int? id;
  ValueNotifier<String> nome = ValueNotifier("");
  ValueNotifier<String> telefoneCelular = ValueNotifier("");
  ValueNotifier<String> telefoneFixo = ValueNotifier("");
  ValueNotifier<List<int>> conhecimentos = ValueNotifier([]);

  void setId(int id) {
    this.id = id;
  }

  void setNome(String? nome) {
    this.nome.value = nome?? "";
    notifyListeners();
  }

  void setTelefoneFixo(String? telefoneFixo) {
    this.telefoneFixo.value = telefoneFixo?? "";
    notifyListeners();
  }

  void setTelefoneCelular(String? telefoneCelular) {
    this.telefoneCelular.value = telefoneCelular?? "";
    notifyListeners();
  }

  void addConhecimentos(int conhecimento) {
    if (!conhecimentos.value.contains(conhecimento)) {
      conhecimentos.value.add(conhecimento);
    }
    notifyListeners();
  }

  void removeConhecimentos(int conhecimento) {
    conhecimentos.value.removeWhere((especialidade) => especialidade == conhecimento);
    notifyListeners();
  }
}

class TecnicoValidator extends LucidValidator<TecnicoForm> {
  final Map<String, String> externalErrors = {};
  final String nomeKey = "nome";
  final String telefoneFixoKey = "telefoneFixo";
  final String telefoneCelularKey = "telefoneCelular";
  final String conhecimentosKey = "conhecimentos";
  List<int> conhecimentos = [];

  TecnicoValidator() {
    ruleFor((tecnico) => tecnico.nome.value, key: nomeKey)
        .must((nome) => nome.isNotEmpty, "O nome é obrigatório!.", nomeKey)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", nomeKey)
        .must((nome) => (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2), "O sobrenome precisa ter 2 caracteres!", nomeKey);

    ruleFor((tecnico) => tecnico.telefoneCelular.value, key: telefoneCelularKey)
        .customValidExternalErrors(externalErrors, telefoneCelularKey);

    ruleFor((tecnico) => tecnico.telefoneFixo.value, key: telefoneFixoKey)
        .customValidExternalErrors(externalErrors, telefoneFixoKey);

    ruleFor((tecnico) => tecnico.conhecimentos.value, key: conhecimentosKey)
        .customValidIsEmpty(conhecimentos, "Selecione ao menos um conhecimento!", conhecimentosKey);
  }

  void applyBackendError(ErrorEntity errorEntity) {
    switch (errorEntity.id) {
      case 1: _addError(nomeKey, errorEntity.errorMessage);
        break;
      case 2: _addError(telefoneFixoKey, errorEntity.errorMessage);
        break;
      case 3: _addError(telefoneCelularKey, errorEntity.errorMessage);
        break;
      case 4: _addListError([telefoneFixoKey, telefoneCelularKey], errorEntity.errorMessage);
        break;
      case 10: _addError(conhecimentosKey, errorEntity.errorMessage);
        break;
    }
  }

  void cleanExternalErrors() {
    externalErrors.clear();
  }

  void setConhecimentos(List<int> conhecimentos) {
    this.conhecimentos.clear();
    this.conhecimentos.addAll(conhecimentos);
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

extension on LucidValidationBuilder<List<int>, TecnicoForm> {
  LucidValidationBuilder<List<int>, TecnicoForm> customValidIsEmpty(List<int> especialidades, String message, String code) {
    ValidationException? callback(value, entity) {
      if(especialidades.isNotEmpty) {
        return null;
      }
      return ValidationException(
        message: message,
        key: code,
        code: code
      );
    }

    return use(callback);
  }
}

// TODO - Refatorar para ser utilizado em qualquer validator
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