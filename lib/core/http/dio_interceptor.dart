import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:serv_oeste/core/observability/app_logger.dart';
import 'package:serv_oeste/shared/services/secure_storage_service.dart';

class DioInterceptor extends Interceptor {
  final JsonEncoder jsonEncoder = const JsonEncoder.withIndent("  ");

  final SecureStorageService _secureStorageService;

  DioInterceptor(this._secureStorageService);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final isAuthRoute = options.path.contains('/auth/login') ||
        options.path.contains('/auth/refresh');

    if (!isAuthRoute) {
      final String? token = await _secureStorageService.getAccessToken();
      if (_secureStorageService.hasToken(token)) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    _limparCookiesDuplicados(options);

    AppLogger.debug('Requisição HTTP', attributes: {
      'http.request.method': options.method,
      'url.full': options.uri.toString(),
      'http.request.base_url': options.baseUrl,
      'http.request.path': options.path,
      'http.request.header': options.headers.toString(),
      if (options.data != null) 'http.request.body': jsonEncoder.convert(options.data),
    });
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

    AppLogger.debug('Resposta HTTP', attributes: {
      'http.response.status_code': response.statusCode ?? 0,
      if (response.data != null)
        'http.response.body': jsonEncoder.convert(response.data),
      if (response.data != null)
        'http.response.body_type': response.data.runtimeType.toString(),
    });
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final authHeader = err.requestOptions.headers['Authorization'];

      if (authHeader is String && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        _analisarToken(token, 'Token que causou 401');
      }

      final cookies = err.requestOptions.headers['cookie'];
      if (cookies is String &&
          _contarOcorrencias(cookies, 'refreshToken') > 1) {
        AppLogger.error('Cookie header corrompido: $cookies');
      }
    }

    AppLogger.error('Falha na requisição HTTP', attributes: {
      'error.type': err.type.name,
      'error.message': err.message ?? '',
      'error.error': err.error?.toString() ?? '',
      if (err.response?.data != null)
        'http.response.body': jsonEncoder.convert(err.response!.data),
    });
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

      AppLogger.debug('Token analisado', attributes: {
        'auth.token_context': contexto,
        'auth.user_id': json['sub']?.toString() ?? 'N/A',
        'auth.role': json['role']?.toString() ?? 'N/A',
        'auth.token_iat': ?iat,
        'auth.token_exp': ?exp,
        if (exp != null) 'auth.token_expires_in_seconds': exp - now,
        if (exp != null) 'auth.token_expired': exp < now,
      });
    } catch (e) {
      AppLogger.warn('Erro ao analisar token: $e');
    }
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
