import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class ClienteForm extends ChangeNotifier {
  int? id;
  ValueNotifier<String> nome = ValueNotifier("");
  ValueNotifier<String> telefoneCelular = ValueNotifier("");
  ValueNotifier<String> telefoneFixo = ValueNotifier("");
  ValueNotifier<String> cep = ValueNotifier("");
  ValueNotifier<String> endereco = ValueNotifier("");
  ValueNotifier<String> municipio = ValueNotifier("Osasco");
  ValueNotifier<String> bairro = ValueNotifier("");

  void setId(int? id) {
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

class ClienteValidator extends LucidValidator<ClienteForm> {
  final Map<String, String> externalErrors = {};
  final String nomeKey = "nome";
  final String telefoneFixoKey = "telefoneFixo";
  final String telefoneCelularKey = "telefoneCelular";
  final String enderecoKey = "endereco";
  final String municipioKey = "municipio";
  final String bairroKey = "bairro";

  ClienteCreateValidator() {
    ruleFor((cliente) => cliente.nome.value, key: nomeKey)
        .must((nome) => nome.isNotEmpty, "O nome é obrigatório!.", nomeKey)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", nomeKey)
        .must((nome) => (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2), "O sobrenome precisa ter 2 caracteres!", nomeKey);

    ruleFor((cliente) => cliente.telefoneCelular.value, key: telefoneCelularKey)
        .customValidExternalErrors(externalErrors, telefoneCelularKey);

    ruleFor((cliente) => cliente.telefoneFixo.value, key: telefoneFixoKey)
        .customValidExternalErrors(externalErrors, telefoneFixoKey);

    ruleFor((cliente) => cliente.endereco.value, key: enderecoKey)
        .mustHaveNumber();

    ruleFor((cliente) => cliente.municipio.value, key: municipioKey)
        .isNotNull()
        .must((cliente) => cliente!.isNotEmpty, "Selecione um múnicipio", municipioKey);

    ruleFor((cliente) => cliente.bairro.value, key: bairroKey)
        .must((municipio) => municipio.isNotEmpty, "'bairro' cannot be empty", bairroKey);
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
      case 5: _addError(enderecoKey, errorEntity.errorMessage);
        break;
      case 6: _addError(municipioKey, errorEntity.errorMessage);
        break;
      case 7: _addError(bairroKey, errorEntity.errorMessage);
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

extension on LucidValidationBuilder<String, ClienteForm> {
  LucidValidationBuilder<String, ClienteForm> customValidExternalErrors(Map<String, String> externalErrors, String code) {
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