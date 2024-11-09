import 'package:flutter/cupertino.dart';
import 'package:lucid_validation/lucid_validation.dart';

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
  ClienteCreateValidator() {
    ruleFor((form) => form.nome.value, key: "nome")
        .must((nome) => nome.isNotEmpty, "O nome é obrigatório!.", "nome")
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", "nome")
        .must((nome) => nome.split(" ")[1].length > 2, "O sobrenome precisa ter 2 caracteres!", "nome");

    ruleFor((form) => form.endereco.value, key: "endereco")
        .mustHaveNumber();

    ruleFor((form) => form.municipio.value, key: "municipio")
        .isNotNull();

    ruleFor((form) => form.bairro.value, key: "bairro")
        .must((municipio) => municipio.isNotEmpty, "'bairro' cannot be empty", "bairro");
  }
}