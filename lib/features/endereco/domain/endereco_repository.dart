import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/endereco/domain/entities/endereco.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

abstract class EnderecoRepository {
  Future<Either<ErrorEntity, Endereco?>> getEndereco(String cep);
}
