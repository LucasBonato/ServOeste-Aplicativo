import 'package:serv_oeste/api/api_serv_oeste.dart';

import '../../../models/tecnico.dart';

class TecnicoService{
  var api = ServOesteApi();

  Future<List<Tecnico>?> getByIdNomesituacao(int? id, String? nome, String? situacao) {
    return api.getTecnicos(id, nome, situacao);
  }

  Future<Tecnico?> getById(int id) {
    return api.getTecnicoById(id);
  }

  dynamic create(Tecnico tecnico) {
    return api.registerTecnico(tecnico);
  }

  dynamic update(Tecnico tecnico) {
    return api.updateTecnico(tecnico);
  }

  dynamic disableList(List<int> selectedItems) {
    return api.disableListOfTecnicos(selectedItems);
  }
}