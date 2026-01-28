import 'dart:ui';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:serv_oeste/core/services/secure_storage_service.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/clients/dio/auth_interceptor.dart';
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
  final SecureStorageService _secureStorageService;

  bool _authInterceptorsAdded = false;

  DioService(this._secureStorageService) {
    _dio.interceptors.add(CookieManager(_cookieJar));
    if (Constants.isDev) {
      _dio.interceptors.add(DioInterceptor(_secureStorageService));
    }
  }

  void addAuthInterceptors(
    AuthClient authClient,
    VoidCallback? onTokenRefreshFailed,
  ) {
    if (_authInterceptorsAdded) {
      return;
    }

    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorageService),
      TokenRefreshInterceptor(
        secureStorageService: _secureStorageService,
        dio: _dio,
        authClient: authClient,
        onTokenRefreshFailed: onTokenRefreshFailed,
      ),
    ]);

    _authInterceptorsAdded = true;
  }

  Dio get dio => _dio;
  CookieJar get cookieJar => _cookieJar;
}
