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

    if (e.response?.statusCode == 401) {
      return ErrorEntity(
          id: 0, errorMessage: "Não autorizado. Token inválido ou expirado.");
    }

    if (e.response?.data is Map<String, dynamic>) {
      final responseData = e.response!.data as Map<String, dynamic>;

      if (responseData.containsKey('error')) {
        final errorData = responseData['error'];
        if (errorData is Map<String, dynamic>) {
          for (final key in errorData.keys) {
            if (errorData[key] is List && (errorData[key] as List).isNotEmpty) {
              return ErrorEntity(
                  id: 0,
                  errorMessage: (errorData[key] as List).first.toString());
            }
          }
        }
      }

      if (responseData.containsKey('message')) {
        return ErrorEntity(id: 0, errorMessage: responseData['message']);
      }

      if (responseData.containsKey('detail')) {
        return ErrorEntity(id: 0, errorMessage: responseData['detail']);
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
          id: 0, errorMessage: "Erro no servidor (${e.response?.statusCode})"),
      DioExceptionType.cancel =>
        ErrorEntity(id: 0, errorMessage: "Requisição cancelada"),
      DioExceptionType.unknown ||
      _ =>
        ErrorEntity(id: 0, errorMessage: "Erro inesperado: ${e.message}"),
    };
  }
}
