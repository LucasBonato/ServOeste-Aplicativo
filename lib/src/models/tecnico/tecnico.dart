import 'dart:convert';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/shared/extensions.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

List<Tecnico> tecnicoFromJson(String str) => List<Tecnico>.from(json.decode(str));

class Tecnico {
  int? id;
  String? nome;
  String? sobrenome;
  String? telefoneFixo;
  String? telefoneCelular;
  String? situacao;
  List<Especialidade>? especialidades;
  List<int>? especialidadesIds;
  List<Map<String, dynamic>>? disponibilidade;

  Tecnico({
    this.id,
    this.nome,
    this.sobrenome,
    this.telefoneFixo,
    this.telefoneCelular,
    this.situacao,
    this.especialidades,
    this.especialidadesIds,
    this.disponibilidade
  });

  Tecnico.fromForm(TecnicoForm tecnicoForm) {
    id = tecnicoForm.id;
    nome = tecnicoForm.nome.value;
    situacao = tecnicoForm.situacao.value.toSituation();
    telefoneFixo = Formatters.transformTelefoneMask(tecnicoForm.telefoneFixo.value);
    telefoneCelular = Formatters.transformTelefoneMask(tecnicoForm.telefoneCelular.value);
    especialidadesIds = tecnicoForm.conhecimentos.value;
  }

  factory Tecnico.fromJson(Map<String, dynamic> json) => Tecnico(
    id: json["id"],
    nome: json["nome"],
    sobrenome: json["sobrenome"],
    telefoneFixo: json["telefoneFixo"],
    telefoneCelular: json["telefoneCelular"],
    situacao: json["situacao"],
    especialidades: List<Especialidade>.from(json["especialidades"].map((x) => Especialidade.fromJson(x))),
  );

  @override
  String toString() {
    return 'Tecnico: $nome $sobrenome, Telefone Fixo: $telefoneFixo, Telefone Celular: $telefoneCelular, Situação: $situacao, Especialidades: ${especialidades?.map((e) => e.conhecimento).join(", ")}';
  }
}

class Especialidade {
  int id;
  String conhecimento;

  Especialidade({
    required this.id,
    required this.conhecimento,
  });

  factory Especialidade.fromJson(Map<String, dynamic> json) => Especialidade(
    id: json["id"],
    conhecimento: json["conhecimento"],
  );
}
