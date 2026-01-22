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
  final List<({DioException error, ErrorInterceptorHandler handler})>
      _pendingRequests = [];
  final Set<String> _processedRequests = {};

  TokenRefreshInterceptor({
    required this.dio,
    required this.authClient,
    this.onTokenRefreshFailed,
  });

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path == ServerEndpoints.refreshEndpoint) {
      return handler.next(err);
    }

    if (err.response?.statusCode != 401 && err.response?.statusCode != 403) {
      return handler.next(err);
    }

    final requestId =
        '${err.requestOptions.method}:${err.requestOptions.path}:${DateTime.now().millisecondsSinceEpoch}';

    if (_processedRequests.contains(requestId)) {
      return handler.next(err);
    }

    _processedRequests.add(requestId);

    if (_isRefreshing) {
      _pendingRequests.add((error: err, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshResult = await authClient.refreshToken();

      if (refreshResult.isRight()) {
        final newTokens =
            refreshResult.getOrElse(() => throw Exception('Missing token'));
        await SecureStorageService.saveTokens(
            newTokens.accessToken, newTokens.refreshToken);

        await _retryRequest(err, handler);

        for (final pending in _pendingRequests) {
          await _retryRequest(pending.error, pending.handler);
        }

        _pendingRequests.clear();
        _processedRequests.clear();
        _isRefreshing = false;

        return;
      } else {
        await _handleRefreshFailed(handler, err);
      }
    } catch (e) {
      await _handleRefreshFailed(handler, err);
    } finally {
      if (_isRefreshing) {
        _isRefreshing = false;
      }
    }
  }

  Future<void> _retryRequest(
      DioException err, ErrorInterceptorHandler handler) async {
    try {
      final newAccessToken = await SecureStorageService.getAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw Exception('Token inválido após refresh');
      }

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';

      final requestOptions = Options(
        method: options.method,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        extra: options.extra,
        headers: options.headers,
        responseType: options.responseType,
        contentType: options.contentType,
        validateStatus: options.validateStatus,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        followRedirects: options.followRedirects,
        maxRedirects: options.maxRedirects,
        requestEncoder: options.requestEncoder,
        responseDecoder: options.responseDecoder,
        listFormat: options.listFormat,
      );

      final response = await dio.request(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: requestOptions,
      );

      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  Future<void> _handleRefreshFailed(
      ErrorInterceptorHandler handler, DioException err) async {
    _isRefreshing = false;
    _pendingRequests.clear();
    _processedRequests.clear();

    await SecureStorageService.deleteTokens();
    onTokenRefreshFailed?.call();

    for (final pending in _pendingRequests) {
      pending.handler.next(pending.error);
    }
    _pendingRequests.clear();

    handler.next(err);
  }
}
