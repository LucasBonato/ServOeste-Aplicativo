class ServerEndpoints {
  static const String baseUrl = "http://localhost:8080/api/";

  static const String authEndpoint = "auth";
  static const String loginEndpoint = "auth/login";
  static const String refreshEndpoint = "auth/refresh";
  static const String logoutEndpoint = "auth/logout";

  static const String userEndpoint = "user";

  static const String tecnicoEndpoint = "tecnico";
  static const String tecnicoFindEndpoint = "tecnico/find";
  static const String tecnicoDisponibilidadeEndpoint = "tecnico/disponibilidade";

  static const String clienteEndpoint = "cliente";
  static const String clienteFindEndpoint = "cliente/find";

  static const String servicoEndpoint = "servico";
  static const String servicoFilterEndpoint = "servico/find";
  static const String servicoMaisClienteEndpoint = "servico/cliente";

  static const String enderecoEndpoint = "endereco";
}
