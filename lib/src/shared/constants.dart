class Constants {
  static const bool isDev = true;

  static const List<Map<String, dynamic>> situationTecnicoList = [
    {'label': 'Ativo', 'value': 'Ativo'},
    {'label': 'Licenca', 'value': 'Licenca'},
    {'label': 'Desativado', 'value': 'Desativado'}
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
    'Sem Defeito',
    'Fechada'
  ];
  static const List<String> municipios = [
    'Osasco',
    'Carapicuíba',
    'Barueri',
    'Cotia',
    'São Paulo',
    'Itapevi',
  ];
  static List<String> equipamentos = [
    'Adega',
    'Bebedouro',
    'Climatizador',
    'Cooler',
    'Frigobar',
    'Geladeira',
    'Lava Louca',
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
}
