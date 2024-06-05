import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:serv_oeste/models/tecnico.dart';
import 'package:http/http.dart' as http;

import '../models/cliente.dart';
import '../models/endereco.dart';

class ServOesteApi{
  var client = http.Client();
  String baseUri = "http://10.0.2.2:8080/api/v1";

  Future<List<Tecnico>?> getTecnicos(int? id, String? nome, String? situacao) async{
    var uri = Uri.parse("$baseUri/tecnico/find");
    var response = await client.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "id": id,
          "nome": nome,
          "situacao": situacao
        }
    ));

    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
    List<Tecnico> tecnicos = jsonResponse.map((json) => Tecnico.fromJson(json)).toList();
    return tecnicos;
  }
  Future<Tecnico?> getTecnicoById(int id) async{
    var uri = Uri.parse("$baseUri/tecnico/$id");
    var response = await client.get(uri);

    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    dynamic jsonResponse = json.decode(responseBodyUtf8);
    Tecnico tecnico = Tecnico.fromJson(jsonResponse);
    return tecnico;
  }
  Future<dynamic> registerTecnico(Tecnico tecnico) async{
    var response = await client.post(
      Uri.parse("$baseUri/tecnico"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "nome": tecnico.nome,
        "sobrenome": tecnico.sobrenome,
        "telefoneFixo": tecnico.telefoneFixo,
        "telefoneCelular": tecnico.telefoneCelular,
        "especialidades_Ids": tecnico.especialidadesIds,
      }),
    );
    if(response.statusCode != 201){
      dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
      return body;
    }
    return null;
  }
  Future<dynamic> updateTecnico(Tecnico tecnico) async{
    var response = await client.put(
      Uri.parse("$baseUri/tecnico/${tecnico.id}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "nome": tecnico.nome,
        "sobrenome": tecnico.sobrenome,
        "telefoneFixo": tecnico.telefoneFixo,
        "telefoneCelular": tecnico.telefoneCelular,
        "situacao": tecnico.situacao,
        "especialidades_Ids": tecnico.especialidadesIds,
      }),
    );
    if(response.statusCode != 200){
      dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
      return body;
    }
    return null;
  }
  Future<dynamic> disableListOfTecnicos(List<int> selectedItems) async{
    var response = await client.delete(
      Uri.parse("$baseUri/tecnico"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(selectedItems)
    );
    if(response.statusCode != 200){
      Logger().e("Vai ver a API");
    }
    return;
  }

  Future<Cliente?> getClienteById(int id) async{
    var uri = Uri.parse("$baseUri/cliente/$id");
    var response = await client.get(uri);

    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    dynamic jsonResponse = json.decode(responseBodyUtf8);
    Cliente cliente = Cliente.fromJson(jsonResponse);
    return cliente;
  }
  Future<List<Cliente>?> getClientes(String? nome, String? telefoneFixo, String? telefoneCelular, String? endereco) async{
    var uri = Uri.parse("${baseUri}/cliente/find");
    var response = await client.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "nome": nome,
          "telefoneFixo": telefoneFixo,
          "telefoneCelular": telefoneCelular,
          "endereco": endereco
        }
        ));

    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
    List<Cliente> clientes = jsonResponse.map((json) => Cliente.fromJson(json)).toList();
    return clientes;
  }
  Future<dynamic> registerCliente(Cliente cliente, String sobrenome) async{
    var response = await client.post(
      Uri.parse("${baseUri}/cliente"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "nome": cliente.nome,
        "sobrenome": sobrenome,
        "telefoneFixo": cliente.telefoneFixo,
        "telefoneCelular": cliente.telefoneCelular,
        "endereco": cliente.endereco,
        "bairro": cliente.bairro,
        "municipio": cliente.municipio
      }),
    );
    if(response.statusCode != 201){
      dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
      return body;
    }
    return null;
  }
  Future<dynamic> updateCliente(Cliente cliente, String sobrenome) async{
    var response = await client.put(
      Uri.parse("$baseUri/cliente?id=${cliente.id}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "nome": cliente.nome,
        "sobrenome": sobrenome,
        "telefoneFixo": cliente.telefoneFixo,
        "telefoneCelular": cliente.telefoneCelular,
        "endereco": cliente.endereco,
        "bairro": cliente.bairro,
        "municipio": cliente.municipio
      }),
    );
    if(response.statusCode != 200){
      dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
      return body;
    }
    return null;
  }
  Future<dynamic> deletarClientes(List<int> idClientes) async{
    var response = await client.delete(
        Uri.parse("${baseUri}/cliente"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(idClientes)
    );
    if(response.statusCode != 200){
      Logger().e("Cliente não encontrado");
    }
    return;
  }

  Future<String?> getEndereco(String cep) async{
    var uri = Uri.parse("$baseUri?cep=$cep");
    var response = await client.get(uri);

    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    dynamic jsonResponse = json.decode(responseBodyUtf8);
    Endereco? endereco = Endereco.fromJson(jsonResponse);
    return endereco.endereco;
  }
}