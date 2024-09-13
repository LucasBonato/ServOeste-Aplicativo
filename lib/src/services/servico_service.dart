import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/services/api_serv_oeste.dart';

class ServicoService {
  var api = ServOesteApi();

  Future<List<TecnicoDisponivel>> getTecnicosDisponiveis() async {
    return await api.getTecnicosDisponiveis();
  }

  Future<dynamic> cadastrarServicoMaisCliente(ServicoRequest servico, ClienteRequest cliente) async {
    return await api.registerServicoMaisCliente(servico, cliente);
  }

  Future<dynamic> cadastrarServicoComCliente(ServicoRequest servico) async {
    return await api.registerServicoComCliente(servico);
  }
}