import 'package:serv_oeste/api/api_serv_oeste.dart';

import '../models/tecnico.dart';

class TecnicoService{
  var api = ServOesteApi();

  Future<List<Tecnico>?> getAllTecnico() async{
    return api.getAllTecnicos();
  }

  Future<List<Tecnico>?> getByNome(String nome) async{
    return api.getByNome(nome);
  }

  Future<dynamic> create(Tecnico tecnico) async{
    return api.postTecnico(tecnico);
  }

  Future<dynamic> disableList(List<int> selectedItems) {
    return api.disableList(selectedItems);
  }
}