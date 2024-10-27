class Endereco {
  String? endereco;

  Endereco({required this.endereco});

  factory Endereco.fromJson(Map<String, dynamic> json) => Endereco(endereco: json["endereco"]);
}