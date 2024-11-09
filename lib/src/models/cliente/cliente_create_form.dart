import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class ClienteCreateForm extends ChangeNotifier {
  ValueNotifier<String> nome = ValueNotifier("");
  ValueNotifier<String> telefoneCelular = ValueNotifier("");
  ValueNotifier<String> telefoneFixo = ValueNotifier("");
  ValueNotifier<String> cep = ValueNotifier("");
  ValueNotifier<String> endereco = ValueNotifier("");
  ValueNotifier<String> municipio = ValueNotifier("");
  ValueNotifier<String> bairro = ValueNotifier("");

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

  void setCep(String? cep) {
    this.cep.value = cep?? "";
    notifyListeners();
  }

  void setEndereco(String? endereco) {
    this.endereco.value = endereco?? "";
    notifyListeners();
  }

  void setMunicipio(String? municipio) {
    this.municipio.value = municipio?? "";
    notifyListeners();
  }

  void setBairro(String? bairro) {
    this.bairro.value = bairro?? "";
    notifyListeners();
  }
}

class ClienteCreateValidator extends LucidValidator<ClienteCreateForm> {
  final Map<String, String> externalErrors = {};
  final String nomeKey = "nome";
  final String telefoneFixoKey = "telefoneFixo";
  final String telefoneCelularKey = "telefoneCelular";
  final String enderecoKey = "endereco";
  final String municipioKey = "municipio";
  final String bairroKey = "bairro";

  ClienteCreateValidator() {
    ruleFor((form) => form.nome.value, key: nomeKey)
        .must((nome) => nome.isNotEmpty, "O nome é obrigatório!.", nomeKey)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", nomeKey)
        .must((nome) => (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2), "O sobrenome precisa ter 2 caracteres!", nomeKey);

    ruleFor((form) => form.endereco.value, key: enderecoKey)
        .mustHaveNumber();

    ruleFor((form) => form.municipio.value, key: municipioKey)
        .isNotNull();

    ruleFor((form) => form.bairro.value, key: bairroKey)
        .must((municipio) => municipio.isNotEmpty, "'bairro' cannot be empty", bairroKey);
  }

  ValidationResult validateWithExternalErrors(ClienteCreateForm entity) {
    ValidationResult result = validate(entity);

    for(var entry in externalErrors.entries) {
      result.exceptions.add(
        ValidationException(message: entry.value, key: entry.key, code: "")
      );
    }

    return ValidationResult(isValid: result.exceptions.isEmpty, exceptions: result.exceptions);
  }

  void applyBackendError(ErrorEntity errorEntity) {
    switch (errorEntity.id) {
      case 1: _addError(nomeKey, errorEntity.errorMessage);
        break;
      case 2: _addError(telefoneFixoKey, errorEntity.errorMessage);
        break;
      case 3: _addError(telefoneCelularKey, errorEntity.errorMessage);
        break;
      case 4:
        _addError(telefoneFixoKey, errorEntity.errorMessage);
        _addError(telefoneCelularKey, errorEntity.errorMessage);
        break;
      case 5: _addError(enderecoKey, errorEntity.errorMessage);
        break;
      case 6: _addError(municipioKey, errorEntity.errorMessage);
        break;
      case 7: _addError(bairroKey, errorEntity.errorMessage);
        break;
    }
  }

  void _addError(String key, String message) {
    externalErrors[key] = message;
  }
}