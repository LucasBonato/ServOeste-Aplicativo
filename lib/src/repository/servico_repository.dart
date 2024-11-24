import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:dio/dio.dart';

class ServicoRepository extends DioService {

  Future<List<Servico>?> getServicosByFilter(ServicoFilterRequest servicoFilter) async {
    try {
      final response = await dio.post(
        ServerEndpoints.servicoFilterEndpoint,
        data: {
          'dataAtendimentoPrevistoAntes': (servicoFilter.dataAtendimentoPrevistoAntes != null) ? "${servicoFilter.dataAtendimentoPrevistoAntes!.toIso8601String()}Z" : null,
          'dataAtendimentoPrevistoDepois': (servicoFilter.dataAtendimentoPrevistoDepois != null) ? "${servicoFilter.dataAtendimentoPrevistoDepois!.toIso8601String()}Z" : null,
          'clienteId': servicoFilter.clienteId,
          'tecnicoId': servicoFilter.tecnicoId,
          'filial': servicoFilter.filial,
          'periodo': servicoFilter.periodo,
        }
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Servico.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<List<TecnicoDisponivel>?> getTecnicosDisponiveis() async {
    try {
      final response = await dio.get(
        ServerEndpoints.servicoDisponibilidadeEndpoint
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => TecnicoDisponivel.fromJson(json))
            .toList();
      }
    } on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }

  Future<ErrorEntity?> createServicoComClienteNaoExistente(ServicoRequest servico, ClienteRequest cliente) async {
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
            "municipio": cliente.municipio.replaceAll("í", "i").replaceAll("ã", "a")
          },
          "servicoRequest": {
            "idTecnico": servico.idTecnico,
            "equipamento": servico.equipamento,
            "marca": servico.marca,
            "filial": servico.filial.replaceAll("í", "i"),
            "dataAtendimento": servico.dataAtendimento,
            "horarioPrevisto": servico.horarioPrevisto,
            "descricao": servico.descricao,
          }
        }
      );
    } on DioException catch(e) {
      return onRequestError(e);
    }
    return null;
  }

  Future<ErrorEntity?> createServicoComClienteExistente(ServicoRequest servico) async {
    try {
      await dio.post(
        ServerEndpoints.servicoEndpoint,
        data: {
          "idCliente": servico.idCliente,
          "idTecnico": servico.idTecnico,
          "equipamento": servico.equipamento,
          "marca": servico.marca,
          "filial": servico.filial.replaceAll("í", "i"),
          "dataAtendimento": servico.dataAtendimento,
          "horarioPrevisto": servico.horarioPrevisto,
          "descricao": servico.descricao,
        }
      );
    } on DioException catch(e) {
      return onRequestError(e);
    }
    return null;
  }
}