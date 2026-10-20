import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/core/http/server_endpoints.dart';
import 'package:serv_oeste/core/observability/app_logger.dart';
import 'package:serv_oeste/core/observability/tracing.dart';
import 'package:serv_oeste/shared/services/secure_storage_service.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthRepository authRepository;
  final VoidCallback? onTokenRefreshFailed;
  final VoidCallback? onSessionCleared;
  final SecureStorageService secureStorageService;

  bool _isRefreshing = false;
  final List<({DioException error, ErrorInterceptorHandler handler})> _pendingRequests = [];

  TokenRefreshInterceptor({
    required this.secureStorageService,
    required this.dio,
    required this.authRepository,
    this.onTokenRefreshFailed,
    this.onSessionCleared,
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
      AppLogger.debug(
        'Requisição enfileirada aguardando refresh de token',
        attributes: {
          'http.request.method': err.requestOptions.method,
          'url.path': err.requestOptions.path,
          'http.response.status_code': status ?? -1,
        },
      );
      return;
    }

    _isRefreshing = true;

    try {
      AppLogger.info(
        'Token expirado, atualizando token de acesso',
        attributes: {
          'http.request.method': err.requestOptions.method,
          'url.path': err.requestOptions.path,
          'http.response.status_code': status ?? -1,
        },
      );

      final Either<ErrorEntity, AuthResponse> refreshResult = await authRepository.refreshToken();

      if (refreshResult.isRight()) {
        final AuthResponse newTokens = refreshResult.getOrElse(() => throw Exception('Missing token'));
        await secureStorageService.updateAccessToken(newTokens.accessToken);

        Tracing.currentUserId = Tracing.userIdFromJwt(newTokens.accessToken);

        // Retry the original request — if it fails, propagate the error
        // normally so the client sees the actual response (e.g., 400 validation)
        // instead of being silently swallowed by _fail().
        try {
          await _retry(err, handler);
        } catch (retryError, retryStackTrace) {
          // Retry failed with a non-auth error (e.g., 400 validation).
          // Propagate the original error so the client handles it properly.
          AppLogger.exception(
            retryError,
            stackTrace: retryStackTrace,
            attributes: {
              'exception.context': 'token_refresh_retry_failed',
              'url.path': err.requestOptions.path,
            },
          );
          _pendingRequests.clear();
          return handler.next(err);
        }

        if (_pendingRequests.isNotEmpty) {
          AppLogger.info(
            'Reenviando ${_pendingRequests.length} requisições pendentes com novo token',
            attributes: {'token.refresh.retry_count': _pendingRequests.length},
          );
          for (final pending in _pendingRequests) {
            try {
              await _retry(pending.error, pending.handler);
            } catch (retryError, retryStackTrace) {
              AppLogger.exception(
                retryError,
                stackTrace: retryStackTrace,
                attributes: {
                  'exception.context': 'token_refresh_pending_retry_failed',
                  'url.path': pending.error.requestOptions.path,
                },
              );
              // Let pending retry failures propagate — their handlers will
              // get the error normally.
              handler.next(pending.error);
            }
          }
        }

        _pendingRequests.clear();
      } else {
        // Refresh token itself failed — this is a true auth failure.
        await _fail(err, handler);
      }
    }
    catch (error, stackTrace) {
      // Only catch exceptions from refreshToken(), not from _retry().
      // If refreshToken() throws (e.g., network error), treat as auth failure.
      AppLogger.exception(
        error,
        stackTrace: stackTrace,
        attributes: {'exception.context': 'token_refresh'},
      );
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
      AppLogger.warn(
        'Token inválido após refresh, não foi possível reenviar requisição',
        attributes: {'url.path': err.requestOptions.path},
      );
      throw Exception('Token inválido após refresh');
    }

    final options = err.requestOptions;

    AppLogger.info(
      'Reenviando requisição com novo token',
      attributes: {
        'http.request.method': options.method,
        'url.path': options.path,
      },
    );

    final headers = Map<String, dynamic>.from(options.headers)
      ..remove('Authorization')
      ..remove('authorization');

    headers["Authorization"] = "Bearer $newAccessToken";

    final Response response = await dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: headers,
        contentType: options.contentType,
        responseType: options.responseType,
      ),
    );

    AppLogger.info(
      'Requisição reenviada com sucesso após refresh de token',
      attributes: {
        'http.request.method': options.method,
        'url.path': options.path,
        'http.response.status_code': response.statusCode ?? -1,
      },
    );

    handler.resolve(response);
  }

  Future<void> _fail(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Resolve all pending requests with an empty response so their BLOCs
    // transition to success (empty list) instead of hanging in loading state.
    // These are auth errors (401/403) where refresh failed — safe to resolve
    // with empty data since navigation to login is already triggered.
    for (final pending in _pendingRequests) {
      pending.handler.resolve(
        Response(
          requestOptions: pending.error.requestOptions,
          statusCode: 498,
          data: null,
        ),
      );
    }
    _pendingRequests.clear();

    AppLogger.warn(
      'Falha ao atualizar token de acesso, encerrando sessão',
      attributes: {'url.path': err.requestOptions.path},
    );
    await secureStorageService.deleteTokens();
    onSessionCleared?.call();
    onTokenRefreshFailed?.call();
    handler.resolve(
      Response(
        requestOptions: err.requestOptions,
        statusCode: 498,
        data: null,
      ),
    );
  }
}
