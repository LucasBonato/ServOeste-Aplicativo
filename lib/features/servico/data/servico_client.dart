import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/core/http/server_endpoints.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_request.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter_request.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_request.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/core/errors/error_handler.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class ServicoClient {
  final Dio dio;

  ServicoClient(this.dio);

  Future<Either<ErrorEntity, Servico?>> getServicoById(int id) async {
    try {
      final response = await dio.get("${ServerEndpoints.servicoEndpoint}/$id");
      if (response.data != null && response.data is Map<String, dynamic>) {
        return Right(Servico.fromJson(response.data));
      }
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    } catch (e) {
      Logger().e('Erro inesperado: $e');
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, PageContent<Servico>>> getServicosByFilter(
    ServicoFilterRequest servicoFilter, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.post(ServerEndpoints.servicoFilterEndpoint, data: {
        'servicoId': servicoFilter.id,
        'clienteId': servicoFilter.clienteId,
        'tecnicoId': servicoFilter.tecnicoId,
        'clienteNome': servicoFilter.clienteNome,
        'tecnicoNome': servicoFilter.tecnicoNome,
        'equipamento': servicoFilter.equipamento,
        'situacao': servicoFilter.situacao,
        'garantia': servicoFilter.garantia,
        'filial': servicoFilter.filial,
        'periodo': servicoFilter.periodo,
        'dataAtendimentoPrevistoAntes': servicoFilter.dataAtendimentoPrevistoAntes?.toIso8601String(),
        'dataAtendimentoPrevistoDepois': servicoFilter.dataAtendimentoPrevistoDepois?.toIso8601String(),
        'dataAtendimentoEfetivoAntes': servicoFilter.dataAtendimentoEfetivoAntes?.toIso8601String(),
        'dataAtendimentoEfetivoDepois': servicoFilter.dataAtendimentoEfetivoDepois?.toIso8601String(),
        'dataAberturaAntes': servicoFilter.dataAberturaAntes?.toIso8601String(),
        'dataAberturaDepois': servicoFilter.dataAberturaDepois?.toIso8601String(),
      }, queryParameters: {
        "page": page,
        "size": size,
      });

      if (response.data != null && response.data is Map<String, dynamic>) {
        return Right(PageContent.fromJson(response.data, (json) => Servico.fromJson(json)));
      }
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    } catch (e) {
      Logger().e('Erro inesperado: $e');
    }
    return Right(PageContent.empty());
  }

  Future<Either<ErrorEntity, void>> createServicoComClienteNaoExistente(ServicoRequest servico, ClienteRequest cliente) async {
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
      return Left(ErrorHandler.onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> createServicoComClienteExistente(ServicoRequest servico) async {
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
      return Left(ErrorHandler.onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> update(Servico servico) async {
    try {
      await dio.put(ServerEndpoints.servicoEndpoint, queryParameters: {
        "id": servico.id
      }, data: {
        "idTecnico": servico.idTecnico,
        "idCliente": servico.idCliente,
        "equipamento": servico.equipamento,
        "marca": servico.marca,
        "filial": servico.filial,
        "descricao": servico.descricao,
        "situacao": Formatters.mapSituationToEnumSituation(servico.situacao),
        "formaPagamento": servico.formaPagamento?.replaceAll("é", "e").toUpperCase(),
        "horarioPrevisto": servico.horarioPrevisto,
        "valor": servico.valor,
        "valorComissao": servico.valorComissao,
        "valorPecas": servico.valorPecas,
        "dataFechamento": servico.dataFechamentoString,
        "dataInicioGarantia": servico.dataInicioGarantiaString,
        "dataFimGarantia": servico.dataFimGarantiaString,
        "dataAtendimentoPrevisto": servico.dataAtendimentoPrevistoString,
        "dataAtendimentoEfetiva": servico.dataAtendimentoEfetivoString,
        "dataPagamentoComissao": servico.dataPagamentoComissaoString
      });
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
    return Right(null);
  }

  Future<Either<ErrorEntity, void>> disableListOfServico(List<int> selectedItems) async {
    try {
      await dio.delete(ServerEndpoints.servicoEndpoint, data: jsonEncode(selectedItems));
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
    return Right(null);
  }
}
