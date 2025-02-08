import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
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
          'servicoId': servicoFilter.id,
          'clienteId': servicoFilter.clienteId,
          'tecnicoId': servicoFilter.tecnicoId,
          'clienteNome': servicoFilter.clienteNome,
          'tecnicoNome': servicoFilter.tecnicoNome,
          'equipamento': servicoFilter.equipamento,
          // 'situacao': servicoFilter.situacao,
          // 'garantia': servicoFilter.garantia,
          'filial': servicoFilter.filial,
          'periodo': servicoFilter.periodo,
          'dataAtendimentoPrevistoAntes': servicoFilter.dataAtendimentoPrevistoAntes?.toIso8601String(),
          'dataAtendimentoPrevistoDepois': servicoFilter.dataAtendimentoPrevistoDepois?.toIso8601String(),
          'dataAtendimentoEfetivoAntes': servicoFilter.dataAtendimentoEfetivoAntes?.toIso8601String(),
          'dataAtendimentoEfetivoDepois': servicoFilter.dataAtendimentoEfetivoDepois?.toIso8601String(),
          'dataAberturaAntes': servicoFilter.dataAberturaAntes?.toIso8601String(),
          'dataAberturaDepois': servicoFilter.dataAberturaDepois?.toIso8601String(),
        },
      );

      if (response.data != null && response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) {
              try {
                return Servico.fromJson(json);
              } catch (e) {
                Logger().e('Erro ao converter item para Servico: $e\nDados do item: $json');
                return null;
              }
            })
            .whereType<Servico>()
            .toList();
      }
    } on DioException catch (e) {
      Logger().e('Erro na requisição: ${onRequestError(e)}');
      throw Exception(onRequestError(e));
    } catch (e) {
      Logger().e('Erro inesperado: $e');
    }
    return null;
  }

  Future<ErrorEntity?> createServicoComClienteNaoExistente(ServicoRequest servico, ClienteRequest cliente) async {
    try {
      await dio.post(ServerEndpoints.servicoMaisClienteEndpoint, data: {
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
      });
    } on DioException catch (e) {
      return onRequestError(e);
    }
    return null;
  }

  Future<ErrorEntity?> createServicoComClienteExistente(ServicoRequest servico) async {
    try {
      await dio.post(ServerEndpoints.servicoEndpoint, data: {
        "idCliente": servico.idCliente,
        "idTecnico": servico.idTecnico,
        "equipamento": servico.equipamento,
        "marca": servico.marca,
        "filial": servico.filial.replaceAll("í", "i"),
        "dataAtendimento": servico.dataAtendimento,
        "horarioPrevisto": servico.horarioPrevisto,
        "descricao": servico.descricao,
      });
    } on DioException catch (e) {
      return onRequestError(e);
    }
    return null;
  }

  Future<void> disableListOfServico(List<int> selectedItems) async {
    try {
      await dio.delete(ServerEndpoints.servicoEndpoint, data: jsonEncode(selectedItems));
    } on DioException catch (e) {
      throw Exception(onRequestError(e));
    }
  }
}
