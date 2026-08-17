import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/core/errors/error_handler.dart';
import 'package:serv_oeste/features/specialty/data/specialty_client.dart';
import 'package:serv_oeste/features/specialty/domain/specialty_repository.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

class SpecialtyRepositoryImplementation implements SpecialtyRepository {
  final SpecialtyClient _client;

  SpecialtyRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, List<Especialidade>>> findAll() async {
    try {
      return Right(await _client.findAll());
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
  }
}