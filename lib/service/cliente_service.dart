import 'package:serv_oeste/api/api_serv_oeste.dart';
import 'package:serv_oeste/models/cliente.dart';

class ClienteService{
  var api = ServOesteApi();

  List<Cliente>? getAllCliente(String? nome, String? telefoneFixo, String? telefoneCelular, String? endereco) {
    List<Cliente>? response = [];
    api.getClientes(nome, telefoneFixo, telefoneCelular, endereco)
        .then((clientes) => response = clientes);
    return response;
  }

  List<Cliente>? getByNome(String nome) {
    List<Cliente>? response = [];
    api.getClientes(nome, null, null, null)
        .then((clientes) => response = clientes);
    return response;
  }

  Cliente? getById(int id) {
    Cliente? response;
    api.getClienteById(id)
        .then((cliente) => response = cliente);
    return response;
  }

  dynamic create(Cliente cliente, String sobrenome) {
    api.registerCliente(cliente, sobrenome);
  }

  dynamic update(Cliente cliente, String sobrenome) {
    api.updateCliente(cliente, sobrenome);
  }

  dynamic disableList(List<int> idClientes) {
    api.deletarClientes(idClientes);
  }

  String? getEndereco(String cep) {
    String? response;
    api.getEndereco(cep)
        .then((endereco) => response = endereco);
    return response;
  }
}