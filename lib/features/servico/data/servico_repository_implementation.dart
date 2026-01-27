import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/servico/data/servico_client.dart';
import 'package:serv_oeste/features/servico/domain/servico_repository.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';

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
