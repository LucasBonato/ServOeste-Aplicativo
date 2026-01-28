import 'package:dio/dio.dart';
import 'package:serv_oeste/core/services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorageService;

  AuthInterceptor(this._secureStorageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final String? token = await _secureStorageService.getAccessToken();

    if (_secureStorageService.hasToken(token)) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}
