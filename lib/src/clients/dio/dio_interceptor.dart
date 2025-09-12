import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/services/secure_storage_service.dart';

class DioInterceptor extends Interceptor {
  final Logger _logger = Logger(printer: PrettyPrinter(printEmojis: false));
  final JsonEncoder jsonEncoder = const JsonEncoder.withIndent("  ");

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final isAuthRoute = options.path.contains('/auth/login') ||
        options.path.contains('/auth/refresh');

    if (!isAuthRoute) {
      final token = await SecureStorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    String logMessage = "";
    logMessage += "TimeStamp: ${DateTime.now()}\n";
    logMessage += "FullUri: ${options.uri}\n";
    logMessage += "BaseUri: ${options.baseUrl}\n";
    logMessage += "Endpoint: ${options.path}\n";
    logMessage += "Method: ${options.method}\n";
    logMessage += "Headers: ${options.headers}\n";
    if (options.data != null) {
      logMessage += "Body: ${jsonEncoder.convert(options.data)}\n";
    }

    _logger.i(logMessage);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String logMessage = "";
    logMessage += "TimeStamp: ${DateTime.now()}\n";
    logMessage += "StatusCode: ${response.statusCode}\n";
    if (response.data != null) {
      logMessage += "ResponseBody: ${jsonEncoder.convert(response.data)}\n";
      logMessage += "RuntimeTypeBody: ${response.data.runtimeType}\n";
    }

    _logger.i(logMessage);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String logMessage = "";
    logMessage += "TimeStamp: ${DateTime.now()}\n";
    logMessage += "ErrorType: ${err.type}\n";
    logMessage += "ErrorMessage: ${err.message}\n";
    logMessage += "Error: ${err.error}\n";
    if (err.response != null && err.response!.data != null) {
      logMessage += "ErrorBody: ${jsonEncoder.convert(err.response!.data)}\n";
    }

    _logger.e(logMessage);
    handler.next(err);
  }
}
