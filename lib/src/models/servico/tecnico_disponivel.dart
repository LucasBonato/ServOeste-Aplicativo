import 'dart:convert';

List<TecnicoDisponivel> tecnicoFromJson(String str) =>
    List<TecnicoDisponivel>.from(
        json.decode(str).map((x) => TecnicoDisponivel.fromJson(x)));

class TecnicoDisponivel {
  int? id;
  String? nome;
  int? quantidadeTotalServicos;
  List<Disponibilidade>? disponibilidades;

  TecnicoDisponivel({
    this.id,
    this.nome,
    this.quantidadeTotalServicos,
    this.disponibilidades,
  });

  factory TecnicoDisponivel.fromJson(Map<String, dynamic> json) =>
      TecnicoDisponivel(
        id: json["id"],
        nome: json["nome"],
        quantidadeTotalServicos: json["quantidadeTotalServicos"],
        disponibilidades: json["disponibilidades"] == null
            ? []
            : List<Disponibilidade>.from(json["disponibilidades"]
                .map((x) => Disponibilidade.fromJson(x))),
      );

  @override
  String toString() {
    return 'TecnicoDisponivel(id: $id, nome: $nome, quantidadeTotalServicos: $quantidadeTotalServicos, disponibilidades: $disponibilidades)';
  }
}

class Disponibilidade {
  DateTime? data;
  int? numeroDiaSemana;
  String? nomeDiaSemana;
  String? periodo;
  int? quantidadeServicos;

  Disponibilidade({
    this.data,
    this.numeroDiaSemana,
    this.nomeDiaSemana,
    this.periodo,
    this.quantidadeServicos,
  });

  factory Disponibilidade.fromJson(Map<String, dynamic> json) =>
      Disponibilidade(
        data: DateTime.tryParse(json["data"]),
        numeroDiaSemana: json["numeroDiaSemana"],
        nomeDiaSemana: json["nomeDiaSemana"],
        periodo: json["periodo"],
        quantidadeServicos: json["quantidadeServicos"],
      );

  @override
  String toString() {
    return 'Disponibilidade(data: $data, numeroDiaSemana: $numeroDiaSemana, nomeDiaSemana: $nomeDiaSemana, periodo: $periodo, quantidadeServicos: $quantidadeServicos)';
  }
}
