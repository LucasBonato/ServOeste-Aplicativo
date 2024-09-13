import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'api_serv_oeste.dart';

class ClienteService{
  var api = ServOesteApi();

  Future<List<Cliente>?> getAllCliente(String? nome, String? telefone, String? endereco) async{
    return await api.getClientes(nome, telefone, endereco);
  }

  Future<List<Cliente>?> getByNome(String nome) async{
    return await api.getClientes(nome, null, null);
  }

  Future<Cliente?> getById(int id) async{
    return api.getClienteById(id);
  }

  dynamic create(Cliente cliente, String sobrenome) {
    return api.registerCliente(cliente, sobrenome);
  }

  dynamic update(Cliente cliente, String sobrenome) {
    return api.updateCliente(cliente, sobrenome);
  }

  dynamic disableList(List<int> idClientes) {
    return api.deletarClientes(idClientes);
  }

  Future<String?> getEndereco(String cep) async{
    return await api.getEndereco(cep);
  }
}