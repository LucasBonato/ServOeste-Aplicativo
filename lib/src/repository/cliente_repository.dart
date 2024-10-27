import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';

import '../models/cliente/cliente.dart';

class ClienteRepository extends DioService {
  // Future<List<Cliente>?> getClientes(String? nome, String? telefone, String? endereco) async{
  //   Uri uri = Uri.parse("${ServerEndpoints.baseUrl}${ServerEndpoints.clienteFindEndpoint}");
  //   Logger().i(uri);
  //
  //   final response = await http.Client().post(
  //     uri,
  //     body: jsonEncode({
  //       'nome': nome,
  //       'telefone': telefone,
  //       'endereco': endereco
  //     }),
  //     headers: {
  //       "Content-Type": "application/json; charset=UTF-8;"
  //     }
  //   );
  //   if(response.statusCode != 200) {
  //     Logger().e("erro: ${response.statusCode}");
  //   }
  //
  //   var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
  //   List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
  //   List<Cliente> clientes = jsonResponse.map((json) => Cliente.fromJson(json)).toList();
  //   return clientes;
  // }

  Future<List<Cliente>?> getClientesByFind(String? nome, String? telefone, String? endereco) async {
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

  // Future<Cliente?> getClienteById(int id) async{
  //   var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
  //   dynamic jsonResponse = json.decode(responseBodyUtf8);
  //   Cliente cliente = Cliente.fromJson(jsonResponse);
  //   return cliente;
  // }

  Future<Cliente?> getClienteById(int id) async {
    try {
      final response = await dio.get(
        "${ServerEndpoints.clienteEndpoint}$id"
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }

  // Future<dynamic> registerCliente(Cliente cliente, String sobrenome) async{
  //
  //   if(response.statusCode != 201){
  //     dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
  //     return body;
  //   }
  //   return null;
  // }

  Future<dynamic> postCliente(Cliente cliente, String sobrenome) async {
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
      return;
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return;
  }

  // Future<dynamic> putCliente(Cliente cliente, String sobrenome) async{
  //   if(response.statusCode != 200){
  //     dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
  //     return body;
  //   }
  //   return null;
  // }

  Future<dynamic> putCliente(Cliente cliente, String sobrenome) async {
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
      if(e.response != null && e.response!.data != null) {

      }
    }
    return;
  }

  // Future<dynamic> deleteClientes(List<int> idClientes) async{
  //   if(response.statusCode != 200){
  //     Logger().e("Cliente não encontrado");
  //   }
  //   return;
  // }

  Future<dynamic> deleteClientes(List<int> idClientes) async {
    try {
      await dio.delete(
        ServerEndpoints.clienteEndpoint,
        data: jsonEncode(idClientes)
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return;
  }
}