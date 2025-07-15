import 'package:dio/dio.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';

class EnderecoClient extends DioService {
  Future<Endereco?> getEndereco(String cep) async{
    try {
      final response = await dio.get(
        ServerEndpoints.enderecoEndpoint,
        queryParameters: {
          "cep": cep
        }
      );

      if (response.data != null) {
        Map<String, dynamic> json = response.data;
        Endereco endereco = Endereco.fromJson(json);
        return endereco;
      }
    }
    on DioException catch(e) {
      throw Exception(onRequestError(e));
    }
    return null;
  }
}