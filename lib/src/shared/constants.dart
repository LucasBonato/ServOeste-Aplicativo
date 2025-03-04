class Constants {
  static const bool isDev = true;

  static const List<String> situationTecnicoList = [
    "Ativo",
    "Licença",
    "Desativado"
  ];

  static const List<String> situationServiceList = [
    'Aguardando agendamento',
    'Aguardando atendimento',
    'Cancelado',
    'Sem defeito',
    'Aguardando orçamento',
    'Aguardando aprovação do cliente',
    'Compra',
    'Não aprovado pelo cliente',
    'Orçamento aprovado',
    'Aguardando cliente retirar',
    'Não retira há 3 meses',
    'Resolvido',
    'Garantia',
    'Cortesia',
  ];

  static const List<String> municipios = [
    'Osasco',
    'Carapicuíba',
    'São Paulo',
    'Barueri',
    'Cotia',
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
    'Fora do período de garantia',
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
    "Selecione uma forma de pagamento*",
    "Pix",
    "Crédito",
    "Débito",
    "Dinheiro",
  ];
}
