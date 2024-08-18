import 'package:serv_oeste/src/models/tecnico_disponivel.dart';
import 'package:serv_oeste/src/services/api_serv_oeste.dart';

class ServicoService {
  var api = ServOesteApi();

  Future<List<TecnicoDisponivel>> getTecnicosDisponiveis(String conhecimento) async {
    return await api.getTecnicosDisponiveis(conhecimento);
  }
}