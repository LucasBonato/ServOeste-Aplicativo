import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';

import '../models/tecnico/tecnico.dart';

class TecnicoClient extends DioService {
  Future<Either<ErrorEntity, PageContent<TecnicoResponse>>> fetchListByFilter({
    int? id,
    String? nome,
    String? telefoneFixo,
    String? telefoneCelular,
    String? situacao,
    String? equipamento,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response =
          await dio.post(ServerEndpoints.tecnicoFindEndpoint, data: {
        "id": id,
        "nome": nome,
        "telefoneFixo": telefoneFixo,
        "telefoneCelular": telefoneCelular,
        "situacao": situacao ?? "ATIVO",
        "equipamento": equipamento,
      }, queryParameters: {
        "page": page,
        "size": size,
      });

      if (response.data is Map<String, dynamic>) {
        return Right(PageContent.fromJson(
          response.data,
          (json) => TecnicoResponse.fromJson(json),
        ));
      }
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right(PageContent.empty());
  }

  Future<Either<ErrorEntity, List<TecnicoDisponivel>>>
      fetchListAvailabilityBySpecialityId(int especialidadeId) async {
    try {
      final response = await dio.post(
          ServerEndpoints.tecnicoDisponibilidadeEndpoint,
          data: {"especialidadeId": especialidadeId});

      if (response.data is List) {
        return Right((response.data as List)
            .map((json) => TecnicoDisponivel.fromJson(json))
            .toList());
      }
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right([]);
  }

  Future<Either<ErrorEntity, Tecnico?>> fetchOneById(int id) async {
    try {
      final response = await dio.get("${ServerEndpoints.tecnicoEndpoint}/$id");

      if (response.data != null) {
        return Right(Tecnico.fromJson(response.data as Map<String, dynamic>));
      }
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> create(Tecnico tecnico) async {
    try {
      await dio.post(ServerEndpoints.tecnicoEndpoint, data: {
        "nome": tecnico.nome,
        "sobrenome": tecnico.sobrenome,
        "telefoneFixo": tecnico.telefoneFixo,
        "telefoneCelular": tecnico.telefoneCelular,
        "especialidades_Ids": tecnico.especialidadesIds
      });
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> update(Tecnico tecnico) async {
    try {
      await dio.put("${ServerEndpoints.tecnicoEndpoint}/${tecnico.id}", data: {
        "nome": tecnico.nome,
        "sobrenome": tecnico.sobrenome,
        "telefoneFixo": tecnico.telefoneFixo,
        "telefoneCelular": tecnico.telefoneCelular,
        "situacao": tecnico.situacao ?? "ativo",
        "especialidades_Ids": tecnico.especialidadesIds,
      });
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> disableListByIds(
      List<int> selectedItems) async {
    try {
      await dio.delete(ServerEndpoints.tecnicoEndpoint,
          data: jsonEncode(selectedItems));
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right(null);
  }
}
