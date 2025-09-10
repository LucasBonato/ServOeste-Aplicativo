import 'package:serv_oeste/src/utils/skeleton/skeleton_generator.dart';
import 'package:serv_oeste/src/utils/skeleton/skeletonizable.dart';

class TecnicoResponse implements Skeletonizable {
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

  factory TecnicoResponse.fromJson(Map<String, dynamic> json) =>
      TecnicoResponse(
        id: json["id"],
        nome: json["nome"],
        sobrenome: json["sobrenome"],
        telefoneFixo: json["telefoneFixo"],
        telefoneCelular: json["telefoneCelular"],
        situacao: json["situacao"],
      );

  @override
  void applySkeletonData() {
    id = SkeletonDataGenerator.integer();
    nome = SkeletonDataGenerator.name();
    sobrenome = SkeletonDataGenerator.name();
    telefoneFixo = SkeletonDataGenerator.phone();
    telefoneCelular = SkeletonDataGenerator.phone();
    situacao = SkeletonDataGenerator.string(length: 7);
  }
}
