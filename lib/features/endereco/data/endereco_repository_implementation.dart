import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/endereco/data/endereco_client.dart';
import 'package:serv_oeste/features/endereco/domain/endereco_repository.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class EnderecoRepositoryImplementation implements EnderecoRepository {
  final EnderecoClient _client;

  EnderecoRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, Endereco?>> getEndereco(String cep) async {
    return await _client.getEndereco(cep);
  }
}
