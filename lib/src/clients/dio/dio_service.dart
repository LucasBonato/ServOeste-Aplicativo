import 'dart:ui';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/clients/dio/dio_interceptor.dart';
import 'package:serv_oeste/src/clients/dio/refresh_token_interceptor.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';

class DioService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ServerEndpoints.baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      receiveTimeout: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  final CookieJar _cookieJar = CookieJar();
  VoidCallback? _onTokenRefreshFailed;

  DioService() {
    _dio.interceptors.add(CookieManager(_cookieJar));

    if (Constants.isDev) {
      _dio.interceptors.add(DioInterceptor());
    }
  }

  void addRefreshInterceptor(AuthClient authClient,
      {VoidCallback? onTokenRefreshFailed}) {
    _onTokenRefreshFailed = onTokenRefreshFailed;

    _dio.interceptors.add(TokenRefreshInterceptor(authClient, _dio,
        onTokenRefreshFailed: _onTokenRefreshFailed));
  }

  Dio get dio => _dio;

  CookieJar get cookieJar => _cookieJar;
}
