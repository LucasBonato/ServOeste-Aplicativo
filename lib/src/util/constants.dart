import 'package:serv_oeste/src/models/tecnico.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';

class Constants {
  static const String baseUri = "http://localhost:8080/api/v1";
  //static const String baseUri = "http://10.0.2.2:8080/api/v1";

  static const List<String> list = ['Ativo', 'Licença', 'Desativado'];
  static const List<String> municipios = ['Osasco', 'Barueri', 'Cotia', 'São Paulo', 'Itapevi', 'Carapicuíba'];
  static const List<String> equipamentos = ["Adega", "Bebedouro", "Climatizador", "Cooler", "Frigobar", "Geladeira", "Lava Louça", "Lava Roupa", "Microondas", "Putificador", "Secadora"];
  static const List<String> marcas = ["Brastemp", "Consul", "Electrolux", "Samsung"];
  static const List<String> filiais = ["Osasco", "Carapicuíba"];
  static const List<String> dataAtendimento = ["Manhã", "Tarde"];

  static String deTransformarMask(String telefone) {
    return "(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
  }

  static String transformarMask(String telefone){
    if(telefone.length != 15) return "";
    return telefone.substring(1, 3) + telefone.substring(5, 10) + telefone.substring(11);
  }

  static String transformTelefone({Tecnico? tecnico, Cliente? cliente}){
    String telefoneC;
    String telefoneF;
    if(tecnico == null) {
      telefoneC = cliente?.telefoneCelular ?? "";
      telefoneF = cliente?.telefoneFixo ?? "";
    } else {
      telefoneC = tecnico.telefoneCelular ?? "";
      telefoneF = tecnico.telefoneFixo ?? "";
    }
    String telefone = (telefoneC.isNotEmpty) ? telefoneC : telefoneF;
    String telefoneFormatado = "Telefone: (${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
    return telefoneFormatado;
  }
}