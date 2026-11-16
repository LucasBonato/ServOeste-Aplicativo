class Constants {
  static const bool isDev = true;

  static const Map<String, String> roleUserMap = {
    'Administrador': 'ADMIN',
    'Balcão': 'EMPLOYEE',
    'Técnico': 'TECHNICIAN',
  };

  static const List<String> roleUserDisplayList = ['Balcão', 'Técnico'];

  static const List<String> situationTecnicoList = [
    "Ativo",
    "Licença",
    "Desativado",
  ];

  static const List<String> municipios = [
    'Osasco',
    'Carapicuíba',
    'São Paulo',
    'Barueri',
    'Cotia',
    'Itapevi',
  ];

  static const List<String> equipamentosFallback = [
    'Adega',
    'Air Fryer',
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
    "Britânia",
    "Cadence",
    "Consul",
    "Continental",
    "Electrolux",
    "Esmaltec",
    "GE",
    "IBBL",
    "Latina",
    "Philco",
    "Samsung",
  ];

  static const List<String> garantias = [
    'Dentro do período de garantia',
    'Fora do período de garantia',
  ];

  static const List<String> filiais = ["Osasco", "Carapicuíba"];

  static String filialFromStored(String stored) => filiais.firstWhere(
    (filial) => filial.replaceAll('í', 'i') == stored,
    orElse: () => stored,
  );

  static const List<String> formasPagamento = [
    "Pix",
    "Crédito",
    "Débito",
    "Dinheiro",
  ];
}
