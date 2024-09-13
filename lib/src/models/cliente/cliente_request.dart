class ClienteRequest {
  String nome;
  String sobrenome;
  String telefoneFixo;
  String telefoneCelular;
  String endereco;
  String bairro;
  String municipio;

  ClienteRequest({
    required this.nome,
    required this.sobrenome,
    required this.telefoneFixo,
    required this.telefoneCelular,
    required this.endereco,
    required this.bairro,
    required this.municipio,
  });
}