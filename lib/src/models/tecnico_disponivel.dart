import 'dart:convert';

List<TecnicoDisponivel> tecnicoFromJson(String str) => List<TecnicoDisponivel>.from(json.decode(str));
class TecnicoDisponivel {
  int? id;
  String? data;
  int? dia;
  String? periodo;
  String? nome;
  int? quantidade;

  TecnicoDisponivel({
    this.id,
    this.data,
    this.dia,
    this.periodo,
    this.nome,
    this.quantidade
  });

  factory TecnicoDisponivel.fromJson(Map<String, dynamic> json) => TecnicoDisponivel(
    id: json["id"],
    data: json["data"],
    dia: json["dia"],
    periodo: json["periodo"],
    nome: json["nome"],
    quantidade: json["quantidade"]
  );
}