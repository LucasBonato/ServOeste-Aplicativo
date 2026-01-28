import 'package:dartz/dartz.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

abstract class EnderecoRepository {
  Future<Either<ErrorEntity, Endereco?>> getEndereco(String cep);
}
