class Constants {
  static const bool isDev = true;

  static const List<String> situationTecnicoList = [
    "Ativo",
    "Licença",
    "Desativado"
  ];

  static const List<String> situationServiceList = [
    'Aguardando agendamento',
    'Aguardando aprovação do cliente',
    'Aguardando atendimento',
    'Aguardando cliente retirar',
    'Aguardando orçamento',
    'Cancelado',
    'Compra',
    'Cortesia',
    'Garantia',
    'Não aprovado pelo cliente',
    'Não retira há 3 meses',
    'Orçamento aprovado',
    'Resolvido',
    'Sem defeito'
  ];

  static const List<String> municipios = [
    'Osasco',
    'Carapicuíba',
    'Barueri',
    'Cotia',
    'São Paulo',
    'Itapevi',
  ];

  static const List<String> equipamentos = [
    'Adega',
    'Bebedouro',
    'Climatizador',
    'Cooler',
    'Frigobar',
    'Geladeira',
    'Lava Louça',
    'Lava Roupa',
    'Microondas',
    'Purificador',
    'Secadora',
  ];

  static const List<String> marcas = [
    "Brastemp",
    "Consul",
    "Electrolux",
    "Samsung"
  ];

  static const List<String> garantias = [
    'Dentro do período de garantia',
    'Fora do período de garantia'
  ];

  static const List<String> filiais = [
    "Selecione uma filial*",
    "Osasco",
    "Carapicuíba",
  ];

  static const List<String> dataAtendimento = [
    "Selecione um horário",
    "manha",
    "tarde",
  ];

  static const List<String> formasPagamento = [
    "Selecione uma forma de pagamento",
    "Pix",
    "Crédito",
    "Débito",
    "Dinheiro",
  ];

  static String? getFormaDePagamento(String? valor) {
    return valor == "Selecione uma forma de pagamento" ? null : valor;
  }

  static String? getFilialValida(String? valor) {
    return valor == "Selecione uma filial*" ? null : valor;
  }

  static String? getHorarioValido(String? valor) {
    return valor == "Selecione um horário" ? null : valor;
  }
}
