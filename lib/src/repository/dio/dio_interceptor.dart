import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioInterceptor extends Interceptor {

  final Logger _logger = Logger();
  final JsonEncoder jsonEncoder = const JsonEncoder.withIndent("  ");

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String logMessage = "";
    logMessage += "TimeStamp: ${DateTime.now()}\n";
    logMessage += "BaseUri: ${options.baseUrl}\n";
    logMessage += "Endpoint: ${options.path}\n";
    logMessage += "Method: ${options.method}\n";
    if(options.data != null) {
      logMessage += "Body: ${jsonEncoder.convert(options.data)}\n";
    }

    _logger.i(logMessage);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String logMessage = "";
    logMessage += "TimeStamp: ${DateTime.now()}\n";
    logMessage += "StatusCode: ${response.statusCode}\n";
    if(response.data != null) {
      logMessage += "ResponseBody: ${jsonEncoder.convert(response.data)}\n";
      logMessage += "RuntimeTypeBody: ${response.data.runtimeType}\n";
    }

    _logger.i(logMessage);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String logMessage = "";
    logMessage += "TimeStamp: ${DateTime.now()}\n";
    logMessage += "ErrorType: ${err.type}\n";
    logMessage += "ErrorMessage: ${err.message}\n";
    if(err.response != null) {
      logMessage += "ErrorBody: ${jsonEncoder.convert(err.response)}\n";
    }

    _logger.e(logMessage);
    super.onError(err, handler);
  }
}