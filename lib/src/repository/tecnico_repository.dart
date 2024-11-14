import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';

import '../models/tecnico/tecnico.dart';

class TecnicoRepository extends DioService {
  Future<List<Tecnico>?> getTecnicosByFind({int? id, String? nome, String? situacao}) async {
    try {
      final response = await dio.post(
        ServerEndpoints.tecnicoFindEndpoint,
        data: {
          "id": id,
          "nome": nome,
          "situacao": situacao
        }
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Tecnico.fromJson(json))
            .toList();
      }
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<Tecnico?> getTecnicoById(int id) async {
    try {
      final response = await dio.get(
          "${ServerEndpoints.tecnicoEndpoint}$id"
      );

      if (response.data != null) {
        dynamic jsonResponse = json.decode(utf8.decode(response.data));
        return Tecnico.fromJson(jsonResponse);
      }
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<void> postTecnico(Tecnico tecnico) async {
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
      throw Exception(onRequestError(e));
    }
  }

  Future<void> putTecnico(Tecnico tecnico) async {
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
      throw Exception(onRequestError(e));
    }
  }

  Future<void> disableListOfTecnicos(List<int> selectedItems) async {
    try {
      await dio.delete(
        ServerEndpoints.tecnicoEndpoint,
        data: jsonEncode(selectedItems)
      );
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
  }
}