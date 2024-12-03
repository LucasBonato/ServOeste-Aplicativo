import 'package:flutter/material.dart';

class ClienteForm extends ChangeNotifier {
  int? id;
  ValueNotifier<String> nome = ValueNotifier("");
  ValueNotifier<String> telefoneCelular = ValueNotifier("");
  ValueNotifier<String> telefoneFixo = ValueNotifier("");
  ValueNotifier<String> cep = ValueNotifier("");
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

  bool isRequiredFieldsFilled() {
    return (
        nome.value.isNotEmpty &&
            rua.value.isNotEmpty &&
            numero.value.isNotEmpty &&
            complemento.value.isNotEmpty &&
            municipio.value.isNotEmpty &&
            bairro.value.isNotEmpty &&
            (telefoneFixo.value.isNotEmpty || telefoneCelular.value.isNotEmpty)
      );
  }
}