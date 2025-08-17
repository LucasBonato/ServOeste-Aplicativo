import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/clients/dio/dio_interceptor.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class DioService {
  final Dio _dio = Dio(BaseOptions(
      baseUrl: ServerEndpoints.baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      receiveTimeout: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 10)));

  DioService() {
    if (Constants.isDev) {
      _dio.interceptors.add(DioInterceptor());
    }
  }

  Dio get dio => _dio;

  ErrorEntity onRequestError(DioException? e) {
    if (e == null) {
      return ErrorEntity(id: 0, errorMessage: "Erro desconhecido");
    }

    if (e.response?.data is Map<String, dynamic>) {
      Map<String, dynamic> data = (e.response!.data as Map<String, dynamic>)["error"];
      return ErrorEntity.fromJson(data);
    }

    if (e.error is JsonUnsupportedObjectError) {
      try {
        final unsupportedObject =
            (e.error as JsonUnsupportedObjectError).unsupportedObject;

        if (unsupportedObject is Response &&
            unsupportedObject.data is Map<String, dynamic>) {
          return ErrorEntity.fromJson(
              unsupportedObject.data as Map<String, dynamic>);
        }
      } catch (decodeError) {
        Logger().e("Erro ao decodificar e.error como JSON: $decodeError");
      }
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout =>
        ErrorEntity(id: 0, errorMessage: "Tempo de conexão esgotado"),
      DioExceptionType.sendTimeout =>
        ErrorEntity(id: 0, errorMessage: "Tempo de envio esgotado"),
      DioExceptionType.receiveTimeout =>
        ErrorEntity(id: 0, errorMessage: "Tempo de resposta esgotado"),
      DioExceptionType.badResponse => ErrorEntity(
          id: 0, errorMessage: "Erro no servidor => ${e.response?.statusCode}"),
      DioExceptionType.cancel =>
        ErrorEntity(id: 0, errorMessage: "Requisição cancelada"),
      DioExceptionType.unknown ||
      _ =>
        ErrorEntity(id: 0, errorMessage: "Erro inesperado: ${e.message}"),
    };
  }
}
