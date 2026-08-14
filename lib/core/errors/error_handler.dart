import 'package:dio/dio.dart';
import 'package:serv_oeste/core/observability/app_logger.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

class ErrorHandler {
  static ErrorEntity onRequestError(DioException? e) {
    final ErrorEntity entity = _build(e);

    AppLogger.error('Requisição falhou', attributes: {
      'error.type': entity.type,
      'error.title': entity.title,
      'error.status': entity.status,
      'error.detail': entity.detail,
      if (entity.traceId != null) 'error.trace_id': entity.traceId!,
      if (entity.errors.isNotEmpty) 'error.errors': entity.errors.toString(),
    });

    return entity;
  }

  static ErrorEntity _build(DioException? e) {
    if (e == null) {
      return ErrorEntity.global("Erro desconhecido");
    }

    if (e.response?.statusCode == 403) {
      return ErrorEntity.global(
        "Sessão expirada. Faça login novamente.",
        status: 403,
        traceId: e.response?.headers.value('trace-id'),
      );
    }

    if (e.response?.statusCode == 401) {
      return ErrorEntity.global(
        "Não autorizado. Token inválido ou expirado.",
        status: 401,
        traceId: e.response?.headers.value('trace-id'),
      );
    }

    if (e.response?.data is Map<String, dynamic>) {
      Map<String, dynamic> data = (e.response!.data as Map<String, dynamic>);
      return ErrorEntity.fromJson(data).withTraceId(e.response?.headers.value('trace-id'));
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
