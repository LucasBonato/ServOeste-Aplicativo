import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

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

  ClienteRequest.fromClienteForm(
      {required ClienteForm cliente, required this.sobrenome}) {
    nome = cliente.nome.value;
    telefoneFixo = Formatters.transformPhoneMask(cliente.telefoneFixo.value);
    telefoneCelular =
        Formatters.transformPhoneMask(cliente.telefoneCelular.value);
    endereco =
        "${cliente.rua.value}, ${cliente.numero.value}${(cliente.complemento.value.isNotEmpty) ? ", ${cliente.complemento.value}" : ""}";
    bairro = cliente.bairro.value;
    municipio = cliente.municipio.value;
  }
}
