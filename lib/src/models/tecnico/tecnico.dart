import 'dart:convert';

import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';

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

    Tecnico({
        this.id,
        this.nome,
        this.sobrenome,
        this.telefoneFixo,
        this.telefoneCelular,
        this.situacao,
        this.especialidades,
        this.especialidadesIds
    });

    Tecnico.fromForm(TecnicoForm tecnicoForm) {
        id = tecnicoForm.id;
        nome = tecnicoForm.nome.value;
        telefoneFixo = transformTelefoneMask(tecnicoForm.telefoneFixo.value);
        telefoneCelular = transformTelefoneMask(tecnicoForm.telefoneCelular.value);
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

    String transformTelefoneMask(String telefone){
        if(telefone.length != 15) return "";
        return telefone.substring(1, 3) + telefone.substring(5, 10) + telefone.substring(11);
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
