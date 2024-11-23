import 'package:flutter/material.dart';

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

  bool isRequiredFieldsFilled() {
    return (
        nome.value.isNotEmpty &&
        endereco.value.isNotEmpty &&
        municipio.value.isNotEmpty &&
        bairro.value.isNotEmpty &&
        (telefoneFixo.value.isNotEmpty || telefoneCelular.value.isNotEmpty)
      );
  }
}
