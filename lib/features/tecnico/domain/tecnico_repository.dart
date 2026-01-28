import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/servico/domain/entities/tecnico_disponivel.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';

import 'entities/tecnico_response.dart';

abstract class TecnicoRepository {
  Future<Either<ErrorEntity, PageContent<TecnicoResponse>>> fetchListByFilter({
    int? id,
    String? nome,
    String? telefoneFixo,
    String? telefoneCelular,
    String? situacao,
    String? equipamento,
    int page = 0,
    int size = 10,
  });
  Future<Either<ErrorEntity, Tecnico?>> fetchOneById(int id);
  Future<Either<ErrorEntity, List<TecnicoDisponivel>>> fetchListAvailabilityBySpecialityId(int especialidadeId);
  Future<Either<ErrorEntity, void>> disableListByIds(List<int> selectedItems);
  Future<Either<ErrorEntity, void>> update(Tecnico tecnico);
  Future<Either<ErrorEntity, void>> create(Tecnico tecnico);
}
