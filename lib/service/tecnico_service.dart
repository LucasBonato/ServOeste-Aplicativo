import 'package:serv_oeste/api/api_serv_oeste.dart';

import '../models/tecnico.dart';

class TecnicoService{
  var api = ServOesteApi();

  Future<List<Tecnico>?> getByIdNomesituacao(int? id, String? nome, String? situacao) {
    return api.getByIdNomesituacao(id, nome, situacao);
  }

  Future<Tecnico?> getById(int id) {
    return api.getById(id);
  }

  dynamic create(Tecnico tecnico) {
    return api.postTecnico(tecnico);
  }

  dynamic update(Tecnico tecnico) {
    return api.update(tecnico);
  }

  dynamic disableList(List<int> selectedItems) {
    return api.disableList(selectedItems);
  }
}