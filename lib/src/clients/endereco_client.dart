import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class EnderecoClient extends DioService {
  Future<Either<ErrorEntity, Endereco?>> getEndereco(String cep) async{
    try {
      final response = await dio.get(
        ServerEndpoints.enderecoEndpoint,
        queryParameters: {
          "cep": cep
        }
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return Right(Endereco.fromJson(response.data));
      }
    }
    on DioException catch(e) {
      return Left(onRequestError(e));
    }
    return Right(null);
  }
}
