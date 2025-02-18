class TecnicoResponse {
  int? id;
  String? nome;
  String? sobrenome;
  String? telefoneFixo;
  String? telefoneCelular;
  String? situacao;

  TecnicoResponse({
    this.id,
    this.nome,
    this.sobrenome,
    this.telefoneFixo,
    this.telefoneCelular,
    this.situacao,
  });

  factory TecnicoResponse.fromJson(Map<String, dynamic> json) => TecnicoResponse(
    id: json["id"],
    nome: json["nome"],
    sobrenome: json["sobrenome"],
    telefoneFixo: json["telefoneFixo"],
    telefoneCelular: json["telefoneCelular"],
    situacao: json["situacao"],
  );
}