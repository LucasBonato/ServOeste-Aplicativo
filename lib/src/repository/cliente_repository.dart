import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ClienteRepository extends DioService {
  Future<List<Cliente>> fetchListByFilter({String? nome, String? telefone, String? endereco}) async {
    try {
      final Response<dynamic> response = await dio.post(ServerEndpoints.clienteFindEndpoint, data: {
        'nome': nome,
        'telefone': telefone,
        'endereco': endereco,
      });

      if (response.data is List) {
        return (response.data as List).map((json) => Cliente.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
    return [];
  }

  Future<Cliente?> fetchOneById({required int id}) async {
    try {
      final response = await dio.get("${ServerEndpoints.clienteEndpoint}/$id");

      if (response.data != null && response.data is Map) {
        return Cliente.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<void> create(Cliente cliente, String sobrenome) async {
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
      throw Exception(onRequestError(e));
    }
  }

  Future<void> update(Cliente cliente, String sobrenome) async {
    try {
      await dio.put(ServerEndpoints.clienteEndpoint,
      queryParameters: {
        "id": cliente.id
      },
      data: {
        "nome": cliente.nome,
        "sobrenome": sobrenome,
        "telefoneFixo": cliente.telefoneFixo,
        "telefoneCelular": cliente.telefoneCelular,
        "endereco": cliente.endereco,
        "bairro": cliente.bairro,
        "municipio": cliente.municipio,
      });
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
  }

  Future<void> deleteListByIds(List<int> idClientes) async {
    try {
      await dio.delete(ServerEndpoints.clienteEndpoint, data: jsonEncode(idClientes));
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
  }
}