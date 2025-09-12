import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/utils/error_handler.dart';

class EnderecoClient {
  final Dio dio;

  EnderecoClient(this.dio);

  Future<Either<ErrorEntity, Endereco?>> getEndereco(String cep) async {
    try {
      final response = await dio
          .get(ServerEndpoints.enderecoEndpoint, queryParameters: {"cep": cep});

      if (response.data != null && response.data is Map<String, dynamic>) {
        return Right(Endereco.fromJson(response.data));
      }
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
    return Right(null);
  }
}
