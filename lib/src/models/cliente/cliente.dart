import 'dart:convert';

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