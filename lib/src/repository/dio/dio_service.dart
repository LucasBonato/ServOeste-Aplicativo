import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
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

  ErrorEntity? onRequestError(DioException? e) {
    if (e == null) {
      return null;
    }
    if (e.error is JsonUnsupportedObjectError) {
      try {
        final unsupportedObject = (e.error as JsonUnsupportedObjectError).unsupportedObject;

        if (unsupportedObject is Response && unsupportedObject.data is Map<String, dynamic>) {
          return ErrorEntity.fromJson(unsupportedObject.data as Map<String, dynamic>);
        }
      } catch (decodeError) {
        Logger().e("Erro ao decodificar e.error como JSON: $decodeError");
      }
    }
    return null;
  }
}