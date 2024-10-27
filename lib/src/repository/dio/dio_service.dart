import 'package:dio/dio.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class DioService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ServerEndpoints.baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      receiveTimeout: const Duration(seconds: 3),
      connectTimeout: const Duration(seconds: 3)
    )
  );

  DioService() {
    if(Constants.isDev) {
      _dio.interceptors.add(LogInterceptor());
    }
  }

  Dio get dio => _dio;
}