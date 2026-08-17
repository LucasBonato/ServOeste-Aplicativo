import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

abstract class SpecialtyRepository {
  Future<Either<ErrorEntity, List<Especialidade>>> findAll();
}