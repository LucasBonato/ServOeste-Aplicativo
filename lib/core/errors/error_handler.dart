import 'package:dio/dio.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

class ErrorHandler {
  static ErrorEntity onRequestError(DioException? e) {
    if (e == null) {
      return ErrorEntity.global("Erro desconhecido");
    }

    if (e.response?.statusCode == 403) {
      return ErrorEntity.global("Sessão expirada. Faça login novamente.");
    }

    if (e.response?.statusCode == 401) {
      return ErrorEntity.global("Não autorizado. Token inválido ou expirado.");
    }

    if (e.response?.data is Map<String, dynamic>) {
      Map<String, dynamic> data = (e.response!.data as Map<String, dynamic>);
      return ErrorEntity.fromJson(data);
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout => ErrorEntity.global("Tempo de conexão esgotado"),
      DioExceptionType.sendTimeout => ErrorEntity.global("Tempo de envio esgotado"),
      DioExceptionType.receiveTimeout => ErrorEntity.global("Tempo de resposta esgotado"),
      DioExceptionType.badResponse => ErrorEntity.global("Erro no servidor => ${e.response?.statusCode}"),
      DioExceptionType.cancel => ErrorEntity.global("Requisição cancelada"),
      DioExceptionType.unknown || _ => ErrorEntity.global("Erro inesperado: ${e.message}"),
    };
  }
}
