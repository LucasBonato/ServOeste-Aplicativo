import 'dart:convert';

List<Tecnico> tecnicoFromJson(String str) => List<Tecnico>.from(json.decode(str));

String tecnicoToJson(Tecnico data) => json.encode(data.toJson());

class Tecnico{
    int id;
    String nome;
    String sobrenome;
    String telefoneFixo;
    String telefoneCelular;
    String situacao;
    List<Especialidade> especialidades;

    Tecnico({
        required this.id,
        required this.nome,
        required this.sobrenome,
        required this.telefoneFixo,
        required this.telefoneCelular,
        required this.situacao,
        required this.especialidades,
    });

    factory Tecnico.fromJson(Map<String, dynamic> json) => Tecnico(
        id: json["id"],
        nome: json["nome"],
        sobrenome: json["sobrenome"],
        telefoneFixo: json["telefoneFixo"],
        telefoneCelular: json["telefoneCelular"],
        situacao: json["situacao"],
        especialidades: List<Especialidade>.from(json["especialidades"].map((x) => Especialidade.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "sobrenome": sobrenome,
        "telefoneFixo": telefoneFixo,
        "telefoneCelular": telefoneCelular,
        "situacao": situacao,
        "especialidades": List<dynamic>.from(especialidades.map((x) => x.toJson())),
    };
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

    Map<String, dynamic> toJson() => {
        "id": id,
        "conhecimento": conhecimento,
    };
}