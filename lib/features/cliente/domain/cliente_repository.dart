import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';

abstract class ClienteRepository {
  Future<Either<ErrorEntity, PageContent<Cliente>>> fetchListByFilter({
    String? nome,
    String? telefone,
    String? endereco,
    int page = 0,
    int size = 10,
  });

  Future<Either<ErrorEntity, Cliente?>> fetchOneById({required int id});

  Future<Either<ErrorEntity, void>> create(Cliente cliente, String sobrenome);

  Future<Either<ErrorEntity, void>> update(Cliente cliente, String sobrenome);

  Future<Either<ErrorEntity, void>> deleteListByIds(List<int> ids);
}
