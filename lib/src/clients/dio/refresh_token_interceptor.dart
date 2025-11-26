import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/services/secure_storage_service.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthClient authClient;
  final VoidCallback? onTokenRefreshFailed;

  bool _isRefreshing = false;
  final _queue = <Completer<void>>[];

  TokenRefreshInterceptor({
    required this.dio,
    required this.authClient,
    this.onTokenRefreshFailed,
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path == ServerEndpoints.refreshEndpoint) {
      return handler.next(err);
    }

    if (err.response?.statusCode != 401 && err.response?.statusCode != 403) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future;

      return _retryRequest(err, handler);
    }

    _isRefreshing = true;

    try {
      final refreshResult = await authClient.refreshToken();

      if (refreshResult.isRight()) {
        final newTokens = refreshResult.getOrElse(() => throw Exception('Missing token'));
        await SecureStorageService.saveTokens(newTokens.accessToken, newTokens.refreshToken);

        for (final completer in _queue) {
          completer.complete();
        }
        _queue.clear();

        _isRefreshing = false;

        return _retryRequest(err, handler);
      }

      await _handleRefreshFailed(handler, err);
    } catch (_) {
      await _handleRefreshFailed(handler, err);
    }
  }

  Future<void> _retryRequest(DioException err, ErrorInterceptorHandler handler) async {
    final newAccessToken = await SecureStorageService.getAccessToken();

    err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

    final response = await dio.fetch(err.requestOptions);
    return handler.resolve(response);
  }

  Future<void> _handleRefreshFailed(ErrorInterceptorHandler handler, DioException err) async {
    _isRefreshing = false;
    _queue.clear();

    await SecureStorageService.deleteTokens();
    onTokenRefreshFailed?.call();

    handler.next(err);
  }
}
