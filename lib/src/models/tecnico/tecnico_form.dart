import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class TecnicoForm extends ChangeNotifier {
  int? id;
  ValueNotifier<String> nome = ValueNotifier("");
  ValueNotifier<String> telefoneCelular = ValueNotifier("");
  ValueNotifier<String> telefoneFixo = ValueNotifier("");
  ValueNotifier<List<EspecialidadeForm>> conhecimentos = ValueNotifier([]);

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

  // void setConhecimentos(String? key, bool? value) {
  //   if(key == null || value == null) return;
  //   conhecimentos.value[key] = value;
  //   notifyListeners();
  // }
}

class TecnicoValidator extends LucidValidator<TecnicoForm> {
  final EspecialidadeValidator especialidadeValidator = EspecialidadeValidator();
  final Map<String, String> externalErrors = {};
  final String nomeKey = "nome";
  final String telefoneFixoKey = "telefoneFixo";
  final String telefoneCelularKey = "telefoneCelular";
  final String conhecimentosKey = "conhecimentos";

  TecnicoValidator() {
    ruleFor((tecnico) => tecnico.nome.value, key: nomeKey)
        .must((nome) => nome.isNotEmpty, "O nome é obrigatório!.", nomeKey)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", nomeKey)
        .must((nome) => (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2), "O sobrenome precisa ter 2 caracteres!", nomeKey);

    ruleFor((tecnico) => tecnico.telefoneCelular.value, key: telefoneCelularKey)
        .customValidExternalErrors(externalErrors, telefoneCelularKey);

    ruleFor((tecnico) => tecnico.telefoneFixo.value, key: telefoneFixoKey)
        .customValidExternalErrors(externalErrors, telefoneFixoKey);

    // ruleFor((tecnico) => tecnico.conhecimentos.value, key: conhecimentosKey)
    //     .setValidator(especialidadeValidator);
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

  void _addError(String key, String message) {
    externalErrors[key] = message;
  }

  void _addListError(List<String> keys, String message) {
    for (String key in keys) {
      externalErrors[key] = message;
    }
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

// extension on SimpleValidationBuilder<String> {
//   SimpleValidationBuilder<String> setValidatorForList(LucidValidator validator) {
//     return
//   }
// }


class EspecialidadeForm extends ChangeNotifier {
  ValueNotifier<int> id = ValueNotifier(0);
  ValueNotifier<String> conhecimento = ValueNotifier("");

  void setId(int id) {
    this.id.value = id;
    notifyListeners();
  }

  void setConhecimento(String conhecimento) {
    this.conhecimento.value = conhecimento;
    notifyListeners();
  }
}

class EspecialidadeValidator extends LucidValidator<EspecialidadeForm> {
  final Map<String, String> externalErrors = {};
  final String conhecimentoKey = "conhecimento";

  EspecialidadeValidator() {
    ruleFor((especialidade) => especialidade.conhecimento.value, key: conhecimentoKey);
  }

  void applyBackendError(ErrorEntity errorEntity) {
    switch (errorEntity.id) {
      case 10: _addError(conhecimentoKey, errorEntity.errorMessage);
      break;
    }
  }

  void cleanExternalErrors() {
    externalErrors.clear();
  }

  void _addError(String key, String message) {
    externalErrors[key] = message;
  }
}