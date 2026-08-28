import 'package:dio/dio.dart';
import 'package:serv_oeste/core/http/server_endpoints.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';

class SpecialtyClient {
  final Dio _dio;

  SpecialtyClient(this._dio);

  Future<List<Especialidade>> findAll() async {
    final Response response = await _dio.get(ServerEndpoints.especialidadesEndpoint);
    return List<Especialidade>.from(
      (response.data as List).map((json) => Especialidade.fromJson(json)),
    );
  }
}