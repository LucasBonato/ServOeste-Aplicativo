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
  ValueNotifier<String> municipio = ValueNotifier("");
  ValueNotifier<String> bairro = ValueNotifier("");
  ValueNotifier<String> rua = ValueNotifier("");
  ValueNotifier<String> numero = ValueNotifier("");
  ValueNotifier<String> complemento = ValueNotifier("");

  void setId(int? id) {
    this.id = id;
  }

  void setNome(String? nome) {
    this.nome.value = nome ?? "";
    notifyListeners();
  }

  void setTelefoneFixo(String? telefoneFixo) {
    this.telefoneFixo.value = telefoneFixo ?? "";
    notifyListeners();
  }

  void setTelefoneCelular(String? telefoneCelular) {
    this.telefoneCelular.value = telefoneCelular ?? "";
    notifyListeners();
  }

  void setCep(String? cep) {
    this.cep.value = cep ?? "";
    notifyListeners();
  }

  void setMunicipio(String? municipio) {
    this.municipio.value = municipio ?? "";
    notifyListeners();
  }

  void setBairro(String? bairro) {
    this.bairro.value = bairro ?? "";
    notifyListeners();
  }

  void setRua(String? rua) {
    this.rua.value = rua ?? "";
    notifyListeners();
  }

  void setNumero(String? numero) {
    this.numero.value = numero ?? "";
    notifyListeners();
  }

  void setComplemento(String? complemento) {
    this.complemento.value = complemento ?? "";
    notifyListeners();
  }
}

class ClienteValidator extends LucidValidator<ClienteForm> {
  final Map<String, String> externalErrors = {};
  final String nomeKey = "nome";
  final String telefoneFixoKey = "telefoneFixo";
  final String telefoneCelularKey = "telefoneCelular";
  final String municipioKey = "municipio";
  final String bairroKey = "bairro";
  final String ruaKey = "rua";
  final String numeroKey = "numero";
  final String enderecoKey = "endereco";

  ClienteValidator() {
    ruleFor((cliente) => cliente.nome.value, key: nomeKey)
        .must((nome) => nome.trim().contains(" "),
            "Informe o nome e sobrenome!", nomeKey)
        .must((nome) => nome.split(" ").any((parte) => parte.length > 1),
            "O sobrenome precisa ter ao menos 2 caracteres!", nomeKey);

    ruleFor((cliente) => cliente, key: telefoneCelularKey).must(
        (cliente) =>
            cliente.telefoneCelular.value.isNotEmpty ||
            cliente.telefoneFixo.value.isNotEmpty,
        "Informe pelo menos um telefone (celular ou fixo)!",
        telefoneCelularKey);

    ruleFor((cliente) => cliente.telefoneCelular.value, key: telefoneCelularKey)
        .customValidExternalErrors(externalErrors, telefoneCelularKey);

    ruleFor((cliente) => cliente, key: telefoneFixoKey).must(
        (cliente) =>
            cliente.telefoneCelular.value.isNotEmpty ||
            cliente.telefoneFixo.value.isNotEmpty,
        "Informe pelo menos um telefone (celular ou fixo)!",
        telefoneFixoKey);

    ruleFor((cliente) => cliente.telefoneFixo.value, key: telefoneFixoKey)
        .customValidExternalErrors(externalErrors, telefoneFixoKey);

    ruleFor((cliente) => cliente.municipio.value, key: municipioKey)
        .isNotNull()
        .must((municipio) => municipio!.isNotEmpty,
            "O município é obrigatório!", municipioKey);

    ruleFor((cliente) => cliente.bairro.value, key: bairroKey).must(
        (bairro) => bairro.isNotEmpty, "O bairro é obrigatório!", bairroKey);

    ruleFor((cliente) => cliente.rua.value, key: ruaKey)
        .must((rua) => rua.isNotEmpty, "A rua é obrigatória!", ruaKey);

    ruleFor((cliente) => cliente.numero.value, key: numeroKey).must(
        (numero) => numero.isNotEmpty, "O número é obrigatório!", numeroKey);
  }

  void applyBackendError(ErrorEntity errorEntity) {
    switch (errorEntity.id) {
      case 1:
        _addError(nomeKey, errorEntity.errorMessage);
        break;
      case 2:
        _addError(telefoneFixoKey, errorEntity.errorMessage);
        break;
      case 3:
        _addError(telefoneCelularKey, errorEntity.errorMessage);
        break;
      case 4:
        _addListError(
            [telefoneFixoKey, telefoneCelularKey], errorEntity.errorMessage);
        break;
      case 5:
        _addError(municipioKey, errorEntity.errorMessage);
        break;
      case 6:
        _addError(bairroKey, errorEntity.errorMessage);
        break;
      case 7:
      case 8:
        _addError(enderecoKey, errorEntity.errorMessage);
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

extension on LucidValidationBuilder<String, dynamic> {
  LucidValidationBuilder<String, dynamic> customValidExternalErrors(
      Map<String, String> externalErrors, String code) {
    ValidationException? callback(value, entity) {
      if (externalErrors[code] == null) {
        return null;
      }
      return ValidationException(message: externalErrors[code]!, code: code);
    }

    return use(callback);
  }
}
