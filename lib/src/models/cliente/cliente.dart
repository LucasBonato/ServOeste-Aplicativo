import 'dart:convert';

import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/shared/formatters.dart';
import 'package:serv_oeste/src/shared/skeleton/skeleton_generator.dart';
import 'package:serv_oeste/src/shared/skeleton/skeletonizable.dart';

List<Cliente> clienteFromJson(String str) => List<Cliente>.from(json.decode(str));

class Cliente implements Skeletonizable {
  int? id;
  String? nome;
  String? telefoneFixo;
  String? telefoneCelular;
  String? endereco;
  String? bairro;
  String? municipio;

  Cliente({this.id, this.nome, this.telefoneFixo, this.telefoneCelular, this.endereco, this.bairro, this.municipio});

  Cliente.fromForm(ClienteForm clienteForm) {
    id = clienteForm.id;
    nome = clienteForm.nome.value;
    telefoneFixo = Formatters.transformTelefoneMask(clienteForm.telefoneFixo.value);
    telefoneCelular = Formatters.transformTelefoneMask(clienteForm.telefoneCelular.value);
    endereco = "${clienteForm.rua.value}, ${clienteForm.numero.value}${(clienteForm.complemento.value.isNotEmpty) ? ", ${clienteForm.complemento.value}" : ""}";
    bairro = clienteForm.bairro.value;
    municipio = clienteForm.municipio.value;
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
      id: json["id"],
      nome: json["nome"],
      telefoneFixo: json["telefoneFixo"],
      telefoneCelular: json["telefoneCelular"],
      endereco: json["endereco"],
      bairro: json["bairro"],
      municipio: json["municipio"]);

  @override
  void applySkeletonData() {
    id = SkeletonDataGenerator.integer();
    nome = SkeletonDataGenerator.name();
    telefoneFixo = SkeletonDataGenerator.phone();
    telefoneCelular = SkeletonDataGenerator.phone();
    endereco = SkeletonDataGenerator.string(length: 15);
    bairro = SkeletonDataGenerator.string(length: 7);
    municipio = SkeletonDataGenerator.string(length: 7);
  }
}
