import 'dart:convert';

List<TecnicoDisponivel> tecnicoFromJson(String str) => List<TecnicoDisponivel>.from(json.decode(str));
class TecnicoDisponivel {
  int? id;
  String? nome;
  List<Disponibilidade>? disponibilidades;

  TecnicoDisponivel({
    this.id,
    this.nome,
    this.disponibilidades
  });

  factory TecnicoDisponivel.fromJson(Map<String, dynamic> json) => TecnicoDisponivel(
    id: json["id"],
    nome: json["nome"],
    disponibilidades: List<Disponibilidade>.from(json["disponibilidades"].map((x) => Disponibilidade.fromJson(x))),
  );
}

class Disponibilidade {
  String? data;
  int? dia;
  String? periodo;
  int? quantidade;

  Disponibilidade({
    this.data,
    this.dia,
    this.periodo,
    this.quantidade
  });

  factory Disponibilidade.fromJson(Map<String, dynamic> json) => Disponibilidade(
      data: json["data"],
      dia: json["dia"],
      periodo: json["periodo"],
      quantidade: json["quantidade"]
  );
}