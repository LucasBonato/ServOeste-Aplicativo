import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';

import '../models/tecnico/tecnico.dart';

class TecnicoRepository extends DioService {
  Future<List<Tecnico>?> getTecnicosByFind(
      {int? id,
      String? nome,
      String? telefoneFixo,
      String? telefoneCelular,
      String? situacao,
      String? equipamento}) async {
    try {
      final response =
          await dio.post(ServerEndpoints.tecnicoFindEndpoint, data: {
        "id": id,
        "nome": nome,
        "telefoneFixo": telefoneFixo,
        "telefoneCelular": telefoneCelular,
        "situacao": situacao,
        "equipamento": equipamento
      });

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Tecnico.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<Tecnico?> getTecnicoById(int id) async {
    try {
      final response = await dio.get("${ServerEndpoints.tecnicoEndpoint}/$id");

      if (response.data != null) {
        return Tecnico.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<ErrorEntity?> postTecnico(Tecnico tecnico) async {
    try {
      await dio.post(ServerEndpoints.tecnicoEndpoint, data: {
        "nome": tecnico.nome,
        "sobrenome": tecnico.sobrenome,
        "telefoneFixo": tecnico.telefoneFixo,
        "telefoneCelular": tecnico.telefoneCelular,
        "especialidades_Ids": tecnico.especialidadesIds
      });
    } on DioException catch (e) {
      return onRequestError(e);
    }
    return null;
  }

  Future<List<TecnicoDisponivel>?> getTecnicosDisponiveis(int especialidadeId) async {
    try {
      final response = await dio.post(
        ServerEndpoints.tecnicoDisponibilidadeEndpoint,
        data: {
          "especialidadeId": especialidadeId
        }
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => TecnicoDisponivel.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<ErrorEntity?> putTecnico(Tecnico tecnico) async {
    tecnico.situacao ??= 'ativo';
    try {
      await dio.put("${ServerEndpoints.tecnicoEndpoint}/${tecnico.id}", data: {
        "nome": tecnico.nome,
        "sobrenome": tecnico.sobrenome,
        "telefoneFixo": tecnico.telefoneFixo,
        "telefoneCelular": tecnico.telefoneCelular,
        "situacao": tecnico.situacao,
        "especialidades_Ids": tecnico.especialidadesIds,
      });
    } on DioException catch (e) {
      return onRequestError(e);
    }
    return null;
  }

  Future<void> disableListOfTecnicos(List<int> selectedItems) async {
    try {
      await dio.delete(ServerEndpoints.tecnicoEndpoint,
          data: jsonEncode(selectedItems));
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
  }
}
