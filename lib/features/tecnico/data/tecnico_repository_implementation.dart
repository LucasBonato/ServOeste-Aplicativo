
import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/servico/domain/entities/tecnico_disponivel.dart';
import 'package:serv_oeste/features/tecnico/data/tecnico_client.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_response.dart';
import 'package:serv_oeste/features/tecnico/domain/tecnico_repository.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';

class TecnicoRepositoryImplementation implements TecnicoRepository {
  final TecnicoClient _client;

  TecnicoRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, PageContent<TecnicoResponse>>> fetchListByFilter({
    int? id,
    String? nome,
    String? telefoneFixo,
    String? telefoneCelular,
    String? situacao,
    String? equipamento,
    int page = 0,
    int size = 10
  }) async {
    return _client.fetchListByFilter(
      id: id,
      nome: nome,
      telefoneFixo: telefoneFixo,
      telefoneCelular: telefoneCelular,
      situacao: situacao,
      equipamento: equipamento,
      page: page,
      size: size,
    );
  }

  @override
  Future<Either<ErrorEntity, Tecnico?>> fetchOneById(int id) async {
    return _client.fetchOneById(id);
  }

  @override
  Future<Either<ErrorEntity, List<TecnicoDisponivel>>> fetchListAvailabilityBySpecialityId(int especialidadeId) async {
    return _client.fetchListAvailabilityBySpecialityId(especialidadeId);
  }

  @override
  Future<Either<ErrorEntity, void>> disableListByIds(List<int> selectedItems) async {
    return _client.disableListByIds(selectedItems);
  }

  @override
  Future<Either<ErrorEntity, void>> create(Tecnico tecnico) async {
    return _client.create(tecnico);
  }

  @override
  Future<Either<ErrorEntity, void>> update(Tecnico tecnico) async {
    return _client.update(tecnico);
  }
}
