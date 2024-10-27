import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';

import '../models/tecnico/tecnico.dart';

class TecnicoRepository extends DioService {
  // Future<List<Tecnico>?> getTecnicos(int? id, String? nome, String? situacao) async{
  //   var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
  //   List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
  //   List<Tecnico> tecnicos = jsonResponse.map((json) => Tecnico.fromJson(json)).toList();
  //   return tecnicos;
  // }

  Future<List<Tecnico>?> getTecnicosByFind(int? id, String? nome, String? situacao) async {
    try {
      final response = await dio.post(
        ServerEndpoints.tecnicoFindEndpoint,
        data: {
          "id": id,
          "nome": nome,
          "situacao": situacao
        }
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }

  // Future<Tecnico?> getTecnicoById(int id) async{
  //   var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
  //   dynamic jsonResponse = json.decode(responseBodyUtf8);
  //   Tecnico tecnico = Tecnico.fromJson(jsonResponse);
  //   return tecnico;
  // }

  Future<Tecnico?> getTecnicoById(int id) async {
    try {
      final response = await dio.get(
          "${ServerEndpoints.tecnicoEndpoint}$id"
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }

  // Future<dynamic> registerTecnico(Tecnico tecnico) async{
  //   if(response.statusCode != 201){
  //     dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
  //     return body;
  //   }
  //   return null;
  // }

  Future<dynamic> postTecnico(Tecnico tecnico) async {
    try {
      await dio.post(
        ServerEndpoints.tecnicoEndpoint,
        data: {
          "nome": tecnico.nome,
          "sobrenome": tecnico.sobrenome,
          "telefoneFixo": tecnico.telefoneFixo,
          "telefoneCelular": tecnico.telefoneCelular,
          "especialidades_Ids": tecnico.especialidadesIds
        }
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }

  // Future<dynamic> updateTecnico(Tecnico tecnico) async{
  //   if(response.statusCode != 200){
  //     dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
  //     return body;
  //   }
  //   return null;
  // }

  Future<dynamic> putTecnico(Tecnico tecnico) async {
    try {
      await dio.put(
        "${ServerEndpoints.tecnicoEndpoint}${tecnico.id}",
        data: {
          "nome": tecnico.nome,
          "sobrenome": tecnico.sobrenome,
          "telefoneFixo": tecnico.telefoneFixo,
          "telefoneCelular": tecnico.telefoneCelular,
          "situacao": tecnico.situacao,
          "especialidades_Ids": tecnico.especialidadesIds,
        }
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }

  // Future<dynamic> disableListOfTecnicos(List<int> selectedItems) async{
  //   if(response.statusCode != 200){
  //     Logger().e("Vai ver a API");
  //   }
  //   return;
  // }

  Future<dynamic> disableListOfTecnicos(List<int> selectedItems) async {
    try {
      await dio.delete(
        ServerEndpoints.tecnicoEndpoint,
        data: jsonEncode(selectedItems)
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }
}