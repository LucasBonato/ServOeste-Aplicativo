import 'package:dio/dio.dart';
import 'package:serv_oeste/src/repository/dio/dio_service.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';

class EnderecoRepository extends DioService {
  // Future<String?> getEndereco(String cep) async{
  //   var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
  //   dynamic jsonResponse = json.decode(responseBodyUtf8);
  //   Endereco? endereco = Endereco.fromJson(jsonResponse);
  //   return endereco.endereco;
  // }

  Future<String?> getEndereco(String cep) async{
    try {
      final response = await dio.get(
        ServerEndpoints.enderecoEndpoint,
        queryParameters: {
          "cep": cep
        }
      );
    } on DioException catch(e) {
      if(e.response != null && e.response!.data != null) {

      }
    }
    return null;
  }
}