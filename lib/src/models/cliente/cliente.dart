import 'dart:convert';

import 'package:serv_oeste/src/models/cliente/cliente_form.dart';

List<Cliente> clienteFromJson(String str) {
  final List<dynamic> jsonData = json.decode(str);
  return jsonData
      .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
      .toList();
}

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
    telefoneFixo = _transformTelefone(clienteForm.telefoneFixo.value);
    telefoneCelular = _transformTelefone(clienteForm.telefoneCelular.value);
    cep = clienteForm.cep.value;
    bairro = clienteForm.bairro.value;
    municipio = clienteForm.municipio.value;
    rua = clienteForm.rua.value;
    numero = clienteForm.numero.value;
    complemento = clienteForm.complemento.value;
  }

  String _transformTelefone(String telefone) {
    final cleanTelefone = telefone.replaceAll(RegExp(r'\D'), '');
    if (cleanTelefone.length == 10 || cleanTelefone.length == 11) {
      return cleanTelefone;
    }
    throw FormatException("Número de telefone inválido: $telefone");
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json["id"] as int?,
        nome: json["nome"] as String?,
        telefoneFixo: json["telefoneFixo"] as String?,
        telefoneCelular: json["telefoneCelular"] as String?,
        bairro: json["bairro"] as String?,
        cep: json["cep"] as String?,
        municipio: json["municipio"] as String?,
        rua: json["rua"] as String?,
        numero: json["numero"] as String?,
        complemento: json["complemento"] as String?,
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
