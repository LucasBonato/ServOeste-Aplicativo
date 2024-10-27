import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/models/tecnico.dart';
import 'package:http/http.dart' as http;
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/util/constants.dart';

import '../models/cliente/cliente.dart';
import '../../src/models/endereco.dart';

class ServOesteApi{
  var client = http.Client();

  Future<String?> getEndereco(String cep) async{
    var uri = Uri.parse("$baseUri/endereco?cep=$cep");
    var response = await client.get(uri);


    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    dynamic jsonResponse = json.decode(responseBodyUtf8);
    Endereco? endereco = Endereco.fromJson(jsonResponse);
    return endereco.endereco;
  }

  Future<List<TecnicoDisponivel>> getTecnicosDisponiveis() async {
    var uri = Uri.parse("$baseUri/servico/disponibilidade");
    var response = await client.get(uri);


    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
    List<TecnicoDisponivel> tecnicosDisponiveis = jsonResponse.map((json) => TecnicoDisponivel.fromJson(json)).toList();
    return tecnicosDisponiveis;
  }
  Future<dynamic> registerServicoMaisCliente(ServicoRequest servico, ClienteRequest cliente) async {
    var response = await client.post(
      Uri.parse("$baseUri/servico/cliente"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "clienteRequest": {
          "nome": cliente.nome,
          "sobrenome": cliente.sobrenome,
          "telefoneFixo": cliente.telefoneFixo,
          "telefoneCelular": cliente.telefoneCelular,
          "endereco": cliente.endereco,
          "bairro": cliente.bairro,
          "municipio": cliente.municipio
        },
        "servicoRequest": {
          "idTecnico": servico.idTecnico,
          "equipamento": servico.equipamento,
          "marca": servico.marca,
          "filial": servico.filial,
          "dataAtendimento": servico.dataAtendimento,
          "horarioPrevisto": servico.horarioPrevisto,
          "descricao": servico.descricao,
        }
      }),
    );

    if(response.statusCode != 201){
      dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
      return body;
    }

    return null;
  }
  Future<dynamic> registerServicoComCliente(ServicoRequest servico) async {
    var response = await client.post(
      Uri.parse("$baseUri/servico"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "servicoRequest": {
          "idCliente": servico.idCliente,
          "idTecnico": servico.idTecnico,
          "equipamento": servico.equipamento,
          "marca": servico.marca,
          "filial": servico.filial,
          "dataAtendimento": servico.dataAtendimento,
          "horarioPrevisto": servico.horarioPrevisto,
          "descricao": servico.descricao,
        }
      }),
    );

    if(response.statusCode != 201){
      dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
      return body;
    }

    return null;
  }
}