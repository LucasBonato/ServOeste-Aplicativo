import 'package:serv_oeste/src/models/servico/equipamento.dart';

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
  static List<Equipamento> equipamentos = [
    Equipamento(id: 1, conhecimento: 'Adega', label: 'Adega'),
    Equipamento(id: 2, conhecimento: 'Bebedouro', label: 'Bebedouro'),
    Equipamento(id: 3, conhecimento: 'Climatizador', label: 'Climatizador'),
    Equipamento(id: 4, conhecimento: 'Cooler', label: 'Cooler'),
    Equipamento(id: 5, conhecimento: 'Frigobar', label: 'Frigobar'),
    Equipamento(id: 6, conhecimento: 'Geladeira', label: 'Geladeira'),
    Equipamento(id: 7, conhecimento: 'Lava Louca', label: 'Lava Louça'),
    Equipamento(id: 8, conhecimento: 'Lava Roupa', label: 'Lava Roupa'),
    Equipamento(id: 9, conhecimento: 'Microondas', label: 'Microondas'),
    Equipamento(id: 10, conhecimento: 'Purificador', label: 'Purificador'),
    Equipamento(id: 11, conhecimento: 'Secadora', label: 'Secadora'),
    Equipamento(id: 12, conhecimento: 'Outros', label: 'Outros'),
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
