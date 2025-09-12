import 'package:dio/dio.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class ErrorHandler {
  static ErrorEntity onRequestError(DioException? e) {
    if (e == null) {
      return ErrorEntity(id: 0, errorMessage: "Erro desconhecido");
    }

    if (e.response?.statusCode == 403) {
      return ErrorEntity(
          id: 0, errorMessage: "Sessão expirada. Faça login novamente.");
    }

    if (e.response?.data is Map<String, dynamic>) {
      Map<String, dynamic> data =
          (e.response!.data as Map<String, dynamic>)["error"];
      return ErrorEntity.fromJson(data);
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
