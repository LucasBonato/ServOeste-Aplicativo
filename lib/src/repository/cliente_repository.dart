import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ClienteRepository extends DioService {
  Future<List<Cliente>?> getClientesByFind({
    String? nome,
    String? telefone,
    String? rua,
    String? numero,
    String? complemento,
    String? cep,
  }) async {
    final response = await dio.get('/clientes', queryParameters: {
      'nome': nome,
      'telefone': telefone,
      'rua': rua,
      'numero': numero,
      'complemento': complemento,
      'cep': cep,
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Cliente.fromJson(e)).toList();
    }
    return null;
  }

  Future<Cliente?> getClienteById({required int id}) async {
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

  Future<ErrorEntity?> postCliente(Cliente cliente, String sobrenome) async {
    try {
      await dio.post(ServerEndpoints.clienteEndpoint, data: {
        "nome": cliente.nome,
        "sobrenome": sobrenome,
        "telefoneFixo": cliente.telefoneFixo,
        "telefoneCelular": cliente.telefoneCelular,
        "rua": cliente.rua,
        "numero": cliente.numero,
        "complemento": cliente.complemento,
        "cep": cliente.cep,
        "bairro": cliente.bairro,
        "municipio": cliente.municipio
      });
    } on DioException catch (e) {
      return onRequestError(e);
    }
    return null;
  }

  Future<ErrorEntity?> putCliente(Cliente cliente, String sobrenome) async {
    try {
      await dio.put(ServerEndpoints.clienteEndpoint, queryParameters: {
        "id": cliente.id
      }, data: {
        "nome": cliente.nome,
        "sobrenome": sobrenome,
        "telefoneFixo": cliente.telefoneFixo,
        "telefoneCelular": cliente.telefoneCelular,
        "rua": cliente.rua,
        "numero": cliente.numero,
        "complemento": cliente.complemento,
        "cep": cliente.cep,
        "bairro": cliente.bairro,
        "municipio": cliente.municipio
      });
    } on DioException catch (e) {
      return onRequestError(e);
    }
    return null;
  }

  Future<void> deleteClientes(List<int> idClientes) async {
    try {
      await dio.delete(ServerEndpoints.clienteEndpoint,
          data: jsonEncode(idClientes));
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
  }
}
