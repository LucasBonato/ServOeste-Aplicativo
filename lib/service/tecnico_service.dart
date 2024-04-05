import 'package:serv_oeste/api/api_servOeste.dart';

import '../models/tecnico.dart';

class TecnicoService{
  var api = ServOesteApi();

  Future<List<Tecnico>?> getAllTecnico() async{
    return api.getAllTecnicos();
  }
}