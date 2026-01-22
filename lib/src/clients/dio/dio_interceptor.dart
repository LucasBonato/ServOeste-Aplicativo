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

    _limparCookiesDuplicados(options);

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
    if (response.requestOptions.path.contains('/auth/refresh') &&
        response.data != null) {
      final newToken = response.data['accessToken'];
      if (newToken != null) {
        _analisarToken(newToken, 'Novo token recebido');
      }
    }

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
    if (err.response?.statusCode == 401) {
      _logger.w('⚠️ 401 Unauthorized detectado');

      final authHeader = err.requestOptions.headers['Authorization'];
      if (authHeader is String && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        _analisarToken(token, 'Token que causou 401');
      }

      final cookies = err.requestOptions.headers['cookie'];
      if (cookies is String &&
          _contarOcorrencias(cookies, 'refreshToken') > 1) {
        _logger.e('🚨 COOKIES DUPLICADOS DETECTADOS!');
        _logger.e('Cookie header corrompido: $cookies');
      }
    }

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

  void _limparCookiesDuplicados(RequestOptions options) {
    if (options.headers.containsKey('cookie')) {
      final cookieHeader = options.headers['cookie'] as String?;
      if (cookieHeader != null &&
          _contarOcorrencias(cookieHeader, 'refreshToken') > 1) {
        final firstTokenMatch =
            RegExp(r'refreshToken=([^;]+)').firstMatch(cookieHeader);
        if (firstTokenMatch != null) {
          final cleanToken = firstTokenMatch.group(1);
          options.headers['cookie'] = 'refreshToken=$cleanToken';
        } else {
          options.headers.remove('cookie');
        }
      }
    }
  }

  void _analisarToken(String token, String contexto) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);

      final iat = json['iat'] as int?;
      final exp = json['exp'] as int?;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      _logger.d('''
🎯 $contexto:
   👤 Sub: ${json['sub']}
   🎭 Role: ${json['role']}
   📅 IAT: $iat (${_timestampParaData(iat)})
   📅 EXP: $exp (${_timestampParaData(exp)})
   ⏰ Agora: $now
   ⏳ Expira em: ${exp != null ? exp - now : 'N/A'} segundos
   ❌ Expirado? ${exp != null && exp < now}
''');
    } catch (e) {
      _logger.w('Erro ao analisar token: $e');
    }
  }

  String _timestampParaData(int? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}';
  }

  int _contarOcorrencias(String texto, String substring) {
    int count = 0;
    int index = 0;

    while ((index = texto.indexOf(substring, index)) != -1) {
      count++;
      index += substring.length;
    }

    return count;
  }
}
