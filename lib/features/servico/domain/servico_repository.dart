import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_request.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'entities/servico_filter_request.dart';
import 'entities/servico_request.dart';

abstract class ServicoRepository {
  Future<Either<ErrorEntity, PageContent<Servico>>> getServicosByFilter(ServicoFilterRequest servicoFilter, {
    int page = 0,
    int size = 10,
  });

  Future<Either<ErrorEntity, Servico?>> getServicoById(int id);

  Future<Either<ErrorEntity, void>> createServicoComClienteNaoExistente(ServicoRequest servico, ClienteRequest cliente);

  Future<Either<ErrorEntity, void>> createServicoComClienteExistente(ServicoRequest servico);

  Future<Either<ErrorEntity, void>> update(Servico servico);

  Future<Either<ErrorEntity, void>> disableListOfServico(List<int> ids);
}
