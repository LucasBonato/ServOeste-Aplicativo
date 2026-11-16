import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serv_oeste/core/http/refresh_token_interceptor.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/services/secure_storage_service.dart';

void main() {
  test('refreshes once and retries request with new access token', () async {
    final storage = _Storage();
    final repository = _AuthRepository();
    final adapter = _Adapter((options) async {
      if (options.headers['Authorization'] == 'Bearer fresh-token') {
        return ResponseBody.fromString(
          '{"ok":true}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      return ResponseBody.fromString('', 401);
    });
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost/',
        headers: {'Authorization': 'Bearer old-token'},
      ),
    )..httpClientAdapter = adapter;
    dio.interceptors.add(
      TokenRefreshInterceptor(
        secureStorageService: storage,
        dio: dio,
        authRepository: repository,
      ),
    );

    final response = await dio.get<Map<String, dynamic>>('protected');

    expect(response.data, {'ok': true});
    expect(repository.refreshCalls, 1);
    expect(adapter.requests, 2);
  });

  test(
    'does not refresh or loop after retried request is unauthorized',
    () async {
      final storage = _Storage();
      final repository = _AuthRepository();
      final adapter = _Adapter((_) async => ResponseBody.fromString('', 401));
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(
        TokenRefreshInterceptor(
          secureStorageService: storage,
          dio: dio,
          authRepository: repository,
        ),
      );

      await expectLater(dio.get('protected'), throwsA(isA<DioException>()));
      expect(repository.refreshCalls, 1);
      expect(adapter.requests, 2);
    },
  );

  test('login 401 bypasses token refresh', () async {
    final repository = _AuthRepository();
    final adapter = _Adapter((_) async => ResponseBody.fromString('', 401));
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      TokenRefreshInterceptor(
        secureStorageService: _Storage(),
        dio: dio,
        authRepository: repository,
      ),
    );

    await expectLater(dio.post('auth/login'), throwsA(isA<DioException>()));
    expect(repository.refreshCalls, 0);
  });

  test('concurrent unauthorized requests share one refresh', () async {    final storage = _Storage();
    final refreshGate = Completer<void>();
    final repository = _AuthRepository(refreshGate: refreshGate.future);
    late _Adapter adapter;
    adapter = _Adapter((options) async {
      if (adapter.requests == 2) refreshGate.complete();
      if (options.headers['Authorization'] == 'Bearer fresh-token') {
        return ResponseBody.fromString(
          '{"ok":true}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      return ResponseBody.fromString('', 401);
    });
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost/',
        headers: {'Authorization': 'Bearer old-token'},
      ),
    )..httpClientAdapter = adapter;
    dio.interceptors.add(
      TokenRefreshInterceptor(
        secureStorageService: storage,
        dio: dio,
        authRepository: repository,
      ),
    );

    final responses = await Future.wait([
      dio.get<Map<String, dynamic>>('first'),
      dio.get<Map<String, dynamic>>('second'),
    ]);

    expect(responses, hasLength(2));
    expect(repository.refreshCalls, 1);
    expect(adapter.requests, 4);
  });

  test('does not re-attempt refresh after session was cleared', () async {
    final storage = _Storage();
    int sessionExpiredCalls = 0;
    final repository = _AuthRepository(failRefresh: true);
    final adapter = _Adapter((_) async => ResponseBody.fromString('', 401));
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      TokenRefreshInterceptor(
        secureStorageService: storage,
        dio: dio,
        authRepository: repository,
        onTokenRefreshFailed: () => sessionExpiredCalls++,
      ),
    );

    // First request: refresh fails, tokens are cleared, session handler runs.
    await expectLater(dio.get('first'), throwsA(isA<DioException>()));
    // Second request arrives after the failure: must not re-attempt refresh.
    await expectLater(dio.get('second'), throwsA(isA<DioException>()));

    expect(repository.refreshCalls, 1);
    expect(sessionExpiredCalls, 1);
    // Two original requests; the mocked refresh doesn't hit the adapter.
    expect(adapter.requests, 2);
  });
}

class _Adapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) respond;
  int requests = 0;

  _Adapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

class _Storage implements SecureStorageService {
  String? token = 'old-token';

  @override
  bool hasToken(String? token) => token != null && token.isNotEmpty;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<String?> getRefreshToken() async => 'refresh-token';

  @override
  Future<void> updateAccessToken(String accessToken) async =>
      token = accessToken;

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    token = accessToken;
  }

  @override
  Future<void> deleteTokens() async => token = null;
}

class _AuthRepository implements AuthRepository {
  final Future<void>? refreshGate;
  final bool failRefresh;
  int refreshCalls = 0;

  _AuthRepository({this.refreshGate, this.failRefresh = false});

  @override
  Future<Either<ErrorEntity, AuthResponse>> refreshToken() async {
    refreshCalls++;
    await refreshGate;
    if (failRefresh) {
      return Left(ErrorEntity.global('Sessão expirada.'));
    }
    return Right(
      AuthResponse(
        accessToken: 'fresh-token',
        refreshToken: 'refresh-token',
        tokenType: 'Bearer',
        expiresIn: 3600,
      ),
    );
  }

  @override
  Future<Either<ErrorEntity, AuthResponse>> login({
    required String username,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Either<ErrorEntity, void>> logout({
    required String accessToken,
  }) async => throw UnimplementedError();
}
