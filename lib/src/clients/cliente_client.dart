import 'package:dartz/dartz.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';

class ClienteClient extends DioService {
  Future<Either<ErrorEntity, PageContent<Cliente>>> fetchListByFilter({
    String? nome,
    String? telefone,
    String? endereco,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final Response<dynamic> response =
          await dio.post(ServerEndpoints.clienteFindEndpoint, data: {
        'nome': nome,
        'telefone': telefone,
        'endereco': endereco,
      }, queryParameters: {
        "page": page,
        "size": size,
      });

      if (response.data != null && response.data is Map<String, dynamic>) {
        return Right(PageContent.fromJson(
            response.data, (json) => Cliente.fromJson(json)));
      }
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right(PageContent.empty());
  }

  Future<Either<ErrorEntity, Cliente?>> fetchOneById({required int id}) async {
    try {
      final response = await dio.get("${ServerEndpoints.clienteEndpoint}/$id");

      if (response.data != null && response.data is Map) {
        return Right(Cliente.fromJson(response.data as Map<String, dynamic>));
      }
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> create(
      Cliente cliente, String sobrenome) async {
    try {
      await dio.post(ServerEndpoints.clienteEndpoint, data: {
        "nome": cliente.nome,
        "sobrenome": sobrenome,
        "telefoneFixo": cliente.telefoneFixo,
        "telefoneCelular": cliente.telefoneCelular,
        "endereco": cliente.endereco,
        "bairro": cliente.bairro,
        "municipio": cliente.municipio,
      });
    } on DioException catch (e) {
      Left(onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> update(
      Cliente cliente, String sobrenome) async {
    try {
      await dio.put(ServerEndpoints.clienteEndpoint, queryParameters: {
        "id": cliente.id
      }, data: {
        "nome": cliente.nome,
        "sobrenome": sobrenome,
        "telefoneFixo": cliente.telefoneFixo,
        "telefoneCelular": cliente.telefoneCelular,
        "endereco": cliente.endereco,
        "bairro": cliente.bairro,
        "municipio": cliente.municipio,
      });
    } on DioException catch (e) {
      Left(onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> deleteListByIds(
      List<int> idClientes) async {
    try {
      await dio.delete(ServerEndpoints.clienteEndpoint,
          data: jsonEncode(idClientes));
    } on DioException catch (e) {
      Left(onRequestError(e));
    }
    return Right(null);
  }
}
