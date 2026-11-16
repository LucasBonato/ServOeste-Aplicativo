import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/core/http/server_endpoints.dart';
import 'package:serv_oeste/core/observability/app_logger.dart';
import 'package:serv_oeste/core/observability/tracing.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/services/secure_storage_service.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthRepository authRepository;
  final VoidCallback? onTokenRefreshFailed;
  final VoidCallback? onSessionCleared;
  final SecureStorageService secureStorageService;

  Future<bool>? _refreshing;

  TokenRefreshInterceptor({
    required this.secureStorageService,
    required this.dio,
    required this.authRepository,
    this.onTokenRefreshFailed,
    this.onSessionCleared,
  });

  bool _isAuthRoute(String path) => [
    ServerEndpoints.loginEndpoint,
    ServerEndpoints.refreshEndpoint,
    ServerEndpoints.logoutEndpoint,
  ].any((endpoint) => path == endpoint || path.endsWith('/$endpoint'));

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final status = err.response?.statusCode;
    if (_isAuthRoute(options.path) ||
        options.extra['tokenRefreshRetried'] == true ||
        (status != 401 && status != 403)) {
      handler.next(err);
      return;
    }

    final failedAuthorization = options.headers['Authorization']?.toString();
    final currentToken = await secureStorageService.getAccessToken();

    if (!secureStorageService.hasToken(currentToken)) {
      handler.next(err);
      return;
    }

    final tokenChangedSinceRequest =
        failedAuthorization != null &&
        failedAuthorization != 'Bearer $currentToken';
    var refreshed = tokenChangedSinceRequest;
    if (!tokenChangedSinceRequest) {
      final refresh = _refreshing ??= _refreshAccessToken();
      refreshed = await refresh;
      if (identical(_refreshing, refresh)) _refreshing = null;
    }

    if (!refreshed) {
      handler.next(err);
      return;
    }

    final token = await secureStorageService.getAccessToken();
    if (!secureStorageService.hasToken(token)) {
      handler.next(err);
      return;
    }

    final headers = Map<String, dynamic>.from(options.headers)
      ..remove('Authorization')
      ..remove('authorization')
      ..['Authorization'] = 'Bearer $token';
    final retryOptions = options.copyWith(
      headers: headers,
      extra: {...options.extra, 'tokenRefreshRetried': true},
    );

    try {
      handler.resolve(await dio.fetch<dynamic>(retryOptions));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (error, stackTrace) {
      AppLogger.exception(
        error,
        stackTrace: stackTrace,
        attributes: {
          'exception.context': 'token_refresh_retry',
          'url.path': options.path,
        },
      );
      handler.next(err);
    }
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final Either<ErrorEntity, AuthResponse> result = await authRepository
          .refreshToken();
      if (result.isRight()) {
        final tokens = result.getOrElse(
          () => throw StateError('Refresh returned no tokens'),
        );
        if (!secureStorageService.hasToken(tokens.accessToken)) {
          throw StateError('Refresh returned an empty access token');
        }
        await secureStorageService.updateAccessToken(tokens.accessToken);
        Tracing.currentUserId = Tracing.userIdFromJwt(tokens.accessToken);
        return true;
      }
    } catch (error, stackTrace) {
      AppLogger.exception(
        error,
        stackTrace: stackTrace,
        attributes: {'exception.context': 'token_refresh'},
      );
    }

    await secureStorageService.deleteTokens();
    onSessionCleared?.call();
    onTokenRefreshFailed?.call();
    return false;
  }
}
