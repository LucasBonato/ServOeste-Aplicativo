import 'package:serv_oeste/api/api_serv_oeste.dart';
import 'package:serv_oeste/models/cliente.dart';

class ClienteService{
  var api = ServOesteApi();

  Future<List<Cliente>?> getAllCliente(String? nome, String? telefone, String? endereco) async{
    return await api.getClientes(nome, telefone, endereco);
  }

  Future<List<Cliente>?> getByNome(String nome) async{
    return await api.getClientes(nome, null, null);
  }

  Future<Cliente?> getById(int id) async{
    Cliente? response;
    api.getClienteById(id)
        .then((cliente) => response = cliente);
    return response;
  }

  dynamic create(Cliente cliente, String sobrenome) async{
    await api.registerCliente(cliente, sobrenome);
  }

  dynamic update(Cliente cliente, String sobrenome) async{
    await api.updateCliente(cliente, sobrenome);
  }

  dynamic disableList(List<int> idClientes) async{
    await api.deletarClientes(idClientes);
  }

  Future<String?> getEndereco(String cep) async{
    return await api.getEndereco(cep);
  }
}