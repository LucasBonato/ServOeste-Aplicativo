import 'dart:convert';

import 'package:serv_oeste/src/models/cliente/cliente_form.dart';

List<Cliente> clienteFromJson(String str) =>
    List<Cliente>.from(json.decode(str));

class Cliente {
  int? id;
  String? nome;
  String? telefoneFixo;
  String? telefoneCelular;
  String? cep;
  String? bairro;
  String? municipio;
  String? rua;
  String? numero;
  String? complemento;

  Cliente({
    this.id,
    this.nome,
    this.telefoneFixo,
    this.telefoneCelular,
    this.cep,
    this.bairro,
    this.municipio,
    this.rua,
    this.numero,
    this.complemento,
  });

  Cliente.fromForm(ClienteForm clienteForm) {
    id = clienteForm.id;
    nome = clienteForm.nome.value;
    telefoneFixo = transformTelefoneMask(clienteForm.telefoneFixo.value);
    telefoneCelular = transformTelefoneMask(clienteForm.telefoneCelular.value);
    cep = clienteForm.cep.value;
    bairro = clienteForm.bairro.value;
    municipio = clienteForm.municipio.value;
    rua = clienteForm.rua.value;
    numero = clienteForm.numero.value;
    complemento = clienteForm.complemento.value;
  }

  String transformTelefoneMask(String telefone) {
    if (telefone.length != 15) return "";
    return telefone.substring(1, 3) +
        telefone.substring(5, 10) +
        telefone.substring(11);
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json["id"],
        nome: json["nome"],
        telefoneFixo: json["telefoneFixo"],
        telefoneCelular: json["telefoneCelular"],
        bairro: json["bairro"],
        cep: json["cep"],
        municipio: json["municipio"],
        rua: json["rua"],
        numero: json["numero"],
        complemento: json["complemento"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "telefoneFixo": telefoneFixo,
        "telefoneCelular": telefoneCelular,
        "cep": cep,
        "bairro": bairro,
        "municipio": municipio,
        "rua": rua,
        "numero": numero,
        "complemento": complemento,
      };
}
