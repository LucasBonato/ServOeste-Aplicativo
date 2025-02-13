class Constants {
  static const bool isDev = true;
  // static const List<Map<String, dynamic>> situationTecnicoList = [
  //   {'label': 'Ativo', 'value': 'Ativo'},
  //   {'label': 'Licença', 'value': 'Licenca'},
  //   {'label': 'Desativado', 'value': 'Desativado'}
  // ];
  static const List<String> situationTecnicoList = [
    "Ativo",
    "Licença",
    "Desativado"
  ];
  static const List<String> situationServiceList = [
    'Aguardando Agendamento',
    'Aguardando Aprovação do Cliente',
    'Aguardando Atendimento',
    'Aguardando Cliente Retirar',
    'Aguardando Orçamento',
    'Cancelado',
    'Compra',
    'Cortesia',
    'Garantia',
    'Não Aprovado pelo Cliente',
    'Não Retira há 3 Meses',
    'Orçamento Aprovado',
    'Resolvido',
    'Sem Defeito'
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
    'Outros',
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
  static const List<String> filiais = ["Osasco", "Carapicuíba"];
  static const List<String> dataAtendimento = ["Manhã", "Tarde"];
  static const List<String> formasPagamento = [
    "Pix",
    "Crédito",
    "Débito",
    "Dinheiro",
  ];
}
