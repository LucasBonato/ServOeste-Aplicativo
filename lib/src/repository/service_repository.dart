import 'package:dio/dio.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';

import '../models/cliente/cliente_request.dart';
import '../models/servico/servico_request.dart';
import '../models/servico/tecnico_disponivel.dart';

class ServiceRepository extends DioService {
  // Future<List<TecnicoDisponivel>> getTecnicosDisponiveis() async {
  //   var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
  //   List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
  //   List<TecnicoDisponivel> tecnicosDisponiveis = jsonResponse.map((json) => TecnicoDisponivel.fromJson(json)).toList();
  //   return tecnicosDisponiveis;
  // }

  Future<List<TecnicoDisponivel>?> getTecnicosDisponiveis() async {
    try {
      final response = await dio.get(
        ServerEndpoints.servicoDisponibilidadeEndpoint
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }

  // Future<dynamic> registerServicoMaisCliente(ServicoRequest servico, ClienteRequest cliente) async {
  //   if(response.statusCode != 201){
  //     dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
  //     return body;
  //   }
  //
  //   return null;
  // }

  Future<dynamic> postServicoComClienteNaoExistente(ServicoRequest servico, ClienteRequest cliente) async {
    try {
      await dio.post(
        ServerEndpoints.servicoMaisClienteEndpoint,
        data: {
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
        }
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }

  // Future<dynamic> registerServicoComCliente(ServicoRequest servico) async {
  //   if(response.statusCode != 201){
  //     dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
  //     return body;
  //   }
  //
  //   return null;
  // }

  Future<dynamic> postServicoComClienteExistente(ServicoRequest servico) async {
    try {
      await dio.post(
        ServerEndpoints.servicoEndpoint,
        data: {
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
        }
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }
}