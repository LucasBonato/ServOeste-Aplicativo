class ServerEndpoints {
  static const String baseUrl = "http://localhost:8080/api/v1/";

  static const String tecnicoEndpoint = "tecnico";
  static const String tecnicoFindEndpoint = "tecnico/find";
  static const String tecnicoDisponibilidadeEndpoint =
      "tecnico/disponibilidade";

  static const String clienteEndpoint = "cliente";
  static const String clienteFindEndpoint = "cliente/find";

  static const String servicoEndpoint = "servico";
  static const String servicoFilterEndpoint = "servico/find";
  static const String servicoMaisClienteEndpoint = "servico/cliente";

  static const String enderecoEndpoint = "endereco";
}
