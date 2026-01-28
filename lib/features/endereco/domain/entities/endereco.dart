class Endereco {
  String? logradouro;
  String? bairro;
  String? municipio;

  Endereco({
    required this.logradouro,
    required this.bairro,
    required this.municipio,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) => Endereco(
        logradouro: json["logradouro"],
        bairro: json["bairro"],
        municipio: json["municipio"],
      );
}
