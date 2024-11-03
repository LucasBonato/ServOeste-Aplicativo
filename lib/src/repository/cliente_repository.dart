import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';

import '../models/cliente/cliente.dart';

class ClienteRepository extends DioService {

  Future<List<Cliente>?> getClientesByFind({String? nome, String? telefone, String? endereco}) async {
    try {
      final Response<dynamic> response = await dio.post(
        ServerEndpoints.clienteFindEndpoint,
        data: {
          'nome': nome,
          'telefone': telefone,
          'endereco': endereco
        }
      );

      if(response.data is List) {
        return (response.data as List)
          .map((json) => Cliente.fromJson(json))
          .toList();
      }

    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<Cliente?> getClienteById(int id) async {
    try {
      final response = await dio.get(
        "${ServerEndpoints.clienteEndpoint}$id"
      );

      if(response.data != null) {
        dynamic jsonResponse = json.decode(utf8.decode(response.data));
        return Cliente.fromJson(jsonResponse);
      }
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<void> postCliente(Cliente cliente, String sobrenome) async {
    try {
      await dio.post(
        ServerEndpoints.clienteEndpoint,
        data: {
          "nome": cliente.nome,
          "sobrenome": sobrenome,
          "telefoneFixo": cliente.telefoneFixo,
          "telefoneCelular": cliente.telefoneCelular,
          "endereco": cliente.endereco,
          "bairro": cliente.bairro,
          "municipio": cliente.municipio
        }
      );
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
  }

  Future<void> putCliente(Cliente cliente, String sobrenome) async {
    try {
      await dio.put(
        ServerEndpoints.clienteEndpoint,
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
          "municipio": cliente.municipio
        }
      );
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
  }

  Future<void> deleteClientes(List<int> idClientes) async {
    try {
      await dio.delete(
        ServerEndpoints.clienteEndpoint,
        data: jsonEncode(idClientes)
      );
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
  }
}