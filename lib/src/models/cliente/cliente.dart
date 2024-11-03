import 'dart:convert';

import 'package:serv_oeste/src/models/cliente/cliente_create_form.dart';

List<Cliente> clienteFromJson(String str) => List<Cliente>.from(json.decode(str));

class Cliente {
  int? id;
  String? nome;
  String? telefoneFixo;
  String? telefoneCelular;
  String? endereco;
  String? bairro;
  String? municipio;

  Cliente({
    this.id,
    this.nome,
    this.telefoneFixo,
    this.telefoneCelular,
    this.endereco,
    this.bairro,
    this.municipio
  });

  Cliente.fromCreateForm(ClienteCreateForm clienteCreateForm) {
    nome = clienteCreateForm.nome.value;
    telefoneFixo = transformTelefoneMask(clienteCreateForm.telefoneFixo.value);
    telefoneCelular = transformTelefoneMask(clienteCreateForm.telefoneCelular.value);
    endereco = clienteCreateForm.endereco.value;
    bairro = clienteCreateForm.bairro.value;
    municipio = clienteCreateForm.municipio.value;
  }

  String transformTelefoneMask(String telefone){
    if(telefone.length != 15) return "";
    return telefone.substring(1, 3) + telefone.substring(5, 10) + telefone.substring(11);
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json["id"],
    nome: json["nome"],
    telefoneFixo: json["telefoneFixo"],
    telefoneCelular: json["telefoneCelular"],
    endereco: json["endereco"],
    bairro: json["bairro"],
    municipio: json["municipio"]
  );
}