import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/cliente/domain/cliente_repository.dart';
import 'package:serv_oeste/features/cliente/data/cliente_client.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';

class ClienteRepositoryImplementation implements ClienteRepository {
  final ClienteClient _client;

  ClienteRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, PageContent<Cliente>>> fetchListByFilter({
    String? nome,
    String? telefone,
    String? endereco,
    int page = 0,
    int size = 10
  }) async {
    return await _client.fetchListByFilter(
      nome: nome,
      telefone: telefone,
      endereco: endereco,
      page: page,
      size: size,
    );
  }

  @override
  Future<Either<ErrorEntity, Cliente?>> fetchOneById({required int id}) async {
    return await _client.fetchOneById(id: id);
  }

  @override
  Future<Either<ErrorEntity, void>> create(Cliente cliente, String sobrenome) async {
    return _client.create(cliente, sobrenome);
  }

  @override
  Future<Either<ErrorEntity, void>> update(Cliente cliente, String sobrenome) async {
    return _client.update(cliente, sobrenome);
  }

  @override
  Future<Either<ErrorEntity, void>> deleteListByIds(List<int> ids) async {
    return _client.deleteListByIds(ids);
  }
}
