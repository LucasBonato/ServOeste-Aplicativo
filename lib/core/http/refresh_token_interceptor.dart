import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/core/http/server_endpoints.dart';
import 'package:serv_oeste/core/services/secure_storage_service.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthRepository authRepository;
  final VoidCallback? onTokenRefreshFailed;
  final SecureStorageService secureStorageService;

  bool _isRefreshing = false;
  final List<({DioException error, ErrorInterceptorHandler handler})> _pendingRequests = [];

  TokenRefreshInterceptor({
    required this.secureStorageService,
    required this.dio,
    required this.authRepository,
    this.onTokenRefreshFailed,
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path == ServerEndpoints.refreshEndpoint) {
      return handler.next(err);
    }

    final int? status = err.response?.statusCode;
    if (status != 401 && status != 403) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      _pendingRequests.add((error: err, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final Either<ErrorEntity, AuthResponse> refreshResult = await authRepository.refreshToken();

      if (refreshResult.isRight()) {
        final AuthResponse newTokens = refreshResult.getOrElse(() => throw Exception('Missing token'));
        await secureStorageService.saveTokens(
          newTokens.accessToken,
          newTokens.refreshToken,
        );

        await _retry(err, handler);

        for (final pending in _pendingRequests) {
          await _retry(pending.error, pending.handler);
        }

        _pendingRequests.clear();

      }
      else {
        await _fail(err, handler);
      }
    }
    catch (_) {
      await _fail(err, handler);
    }
    finally {
      _isRefreshing = false;
    }
  }

  Future<void> _retry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final String? newAccessToken = await secureStorageService.getAccessToken();
    if (!secureStorageService.hasToken(newAccessToken)) {
      throw Exception('Token inválido após refresh');
    }

    final options = err.requestOptions;

    final Response response = await dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
        contentType: options.contentType,
        responseType: options.responseType,
      ),
    );

    handler.resolve(response);
  }

  Future<void> _fail(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _pendingRequests.clear();
    await secureStorageService.deleteTokens();
    onTokenRefreshFailed?.call();
    handler.next(err);
  }
}
