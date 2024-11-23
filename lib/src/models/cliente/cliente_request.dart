import 'package:serv_oeste/src/models/cliente/cliente_form.dart';

class ClienteRequest {
  late String nome;
  late String sobrenome;
  late String telefoneFixo;
  late String telefoneCelular;
  late String endereco;
  late String bairro;
  late String municipio;

  ClienteRequest({
    required this.nome,
    required this.sobrenome,
    required this.telefoneFixo,
    required this.telefoneCelular,
    required this.endereco,
    required this.bairro,
    required this.municipio,
  });

  ClienteRequest.fromClienteForm({required ClienteForm cliente, required this.sobrenome}) {
    nome = cliente.nome.value;
    telefoneFixo = transformTelefoneMask(cliente.telefoneFixo.value);
    telefoneCelular = transformTelefoneMask(cliente.telefoneCelular.value);
    endereco = cliente.endereco.value;
    bairro = cliente.bairro.value;
    municipio = cliente.municipio.value;
  }

  String transformTelefoneMask(String telefone){
    if(telefone.length != 15) return "";
    return telefone.substring(1, 3) + telefone.substring(5, 10) + telefone.substring(11);
  }
}