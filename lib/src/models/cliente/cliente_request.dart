class ClienteRequest {
  String nome;
  String sobrenome;
  String telefoneFixo;
  String telefoneCelular;
  String cep;
  String bairro;
  String municipio;
  String rua;
  String numero;
  String complemento;

  ClienteRequest({
    required this.nome,
    required this.sobrenome,
    required this.telefoneFixo,
    required this.telefoneCelular,
    required this.cep,
    required this.bairro,
    required this.municipio,
    required this.rua,
    required this.numero,
    required this.complemento,
  });
}
