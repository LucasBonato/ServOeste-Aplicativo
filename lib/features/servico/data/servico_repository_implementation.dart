import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_request.dart';
import 'package:serv_oeste/features/servico/data/servico_client.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter_request.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_request.dart';
import 'package:serv_oeste/features/servico/domain/servico_repository.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';

class ServicoRepositoryImplementation implements ServicoRepository {
  final ServicoClient _client;

  ServicoRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, void>> createServicoComClienteExistente(ServicoRequest servico) {
    return _client.createServicoComClienteExistente(servico);
  }

  @override
  Future<Either<ErrorEntity, void>> createServicoComClienteNaoExistente(ServicoRequest servico, ClienteRequest cliente) {
    return _client.createServicoComClienteNaoExistente(servico, cliente);
  }

  @override
  Future<Either<ErrorEntity, void>> disableListOfServico(List<int> ids) {
    return _client.disableListOfServico(ids);
  }

  @override
  Future<Either<ErrorEntity, Servico?>> getServicoById(int id) {
    return _client.getServicoById(id);
  }

  @override
  Future<Either<ErrorEntity, PageContent<Servico>>> getServicosByFilter(ServicoFilterRequest servicoFilter, {int page = 0, int size = 10}) {
    return _client.getServicosByFilter(servicoFilter, page: page, size: size);
  }

  @override
  Future<Either<ErrorEntity, void>> update(Servico servico) {
    return _client.update(servico);
  }
}
