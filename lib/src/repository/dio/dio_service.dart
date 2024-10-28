import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/dio/dio_interceptor.dart';
import 'package:serv_oeste/src/repository/dio/server_endpoints.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class DioService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ServerEndpoints.baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      receiveTimeout: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 10)
    )
  );

  DioService() {
    if(Constants.isDev) {
      _dio.interceptors.add(DioInterceptor());
    }
  }

  Dio get dio => _dio;

  ErrorEntity? onRequestError(DioException e) {
    if(e.response != null && e.response!.data != null) {
      dynamic json = jsonDecode(e.response!.data);
      ErrorEntity error = ErrorEntity.fromJson(json);
      return error;
    }
    return null;
  }
}