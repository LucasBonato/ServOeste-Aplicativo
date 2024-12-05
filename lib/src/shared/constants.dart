import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';

class Constants {
  static const bool isDev = true;

  static const List<String> situationTecnicoList = [
    '',
    'Ativo',
    'Licença',
    'Desativado'
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
    'Carapicuíba'
        'Barueri',
    'Cotia',
    'São Paulo',
    'Itapevi',
  ];
  static const List<String> equipamentos = [
    "Adega",
    "Bebedouro",
    "Climatizador",
    "Cooler",
    "Frigobar",
    "Geladeira",
    "Lava Louça",
    "Lava Roupa",
    "Microondas",
    "Purificador",
    "Secadora"
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

  static final List<MaskTextInputFormatter> maskCep = [
    MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> maskTelefone = [
    MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> maskTelefoneFixo = [
    MaskTextInputFormatter(
      mask: '(##) ####-####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> maskData = [
    MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];

  // TODO - Retirar os métodos de transformar Mask das Constants
  static String deTransformarMask(String telefone) {
    return "(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
  }

  static String transformTelefoneMask(String telefone){
    if(telefone.length < 14 || telefone.length > 15) return "";
    return telefone.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "");
  }

  static String transformTelefone({Tecnico? tecnico, Cliente? cliente}) {
    String telefoneC;
    String telefoneF;
    if (tecnico == null) {
      telefoneC = cliente?.telefoneCelular ?? "";
      telefoneF = cliente?.telefoneFixo ?? "";
    } else {
      telefoneC = tecnico.telefoneCelular ?? "";
      telefoneF = tecnico.telefoneFixo ?? "";
    }
    String telefone = (telefoneC.isNotEmpty) ? telefoneC : telefoneF;
    String telefoneFormatado =
        "Telefone: (${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
    return telefoneFormatado;
  }
}
