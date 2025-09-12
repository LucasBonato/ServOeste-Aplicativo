import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/services/secure_storage_service.dart';

class TokenRefreshInterceptor extends Interceptor {
  final AuthClient authClient;
  final Dio _dio;
  final VoidCallback? onTokenRefreshFailed;
  bool _isRefreshing = false;

  TokenRefreshInterceptor(this.authClient, this._dio,
      {this.onTokenRefreshFailed});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (_isRefreshing ||
        err.requestOptions.path == ServerEndpoints.refreshEndpoint) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      _isRefreshing = true;

      try {
        final result = await authClient.refreshToken();

        if (result.isRight()) {
          final newTokens = result.fold(
            (left) => null,
            (right) => right,
          );

          if (newTokens != null) {
            await SecureStorageService.saveTokens(
              newTokens.accessToken,
              newTokens.refreshToken,
            );

            err.requestOptions.headers['Authorization'] =
                'Bearer ${newTokens.accessToken}';

            final response = await _dio.request(
              err.requestOptions.path,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
            );

            _isRefreshing = false;
            return handler.resolve(response);
          }
        }

        await _handleTokenRefreshFailed();
      } catch (refreshError) {
        await _handleTokenRefreshFailed();
      }

      handler.next(err);
    } else {
      handler.next(err);
    }
  }

  Future<void> _handleTokenRefreshFailed() async {
    await SecureStorageService.deleteTokens();
    _isRefreshing = false;
    if (onTokenRefreshFailed != null) {
      onTokenRefreshFailed!();
    }
  }
}
