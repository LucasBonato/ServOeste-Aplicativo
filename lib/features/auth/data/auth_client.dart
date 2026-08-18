import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/core/errors/error_handler.dart';
import 'package:serv_oeste/core/http/server_endpoints.dart';
import 'package:serv_oeste/core/observability/otel_metrics.dart';
import 'package:serv_oeste/core/observability/tracing.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth_request.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

class AuthClient {
  final Dio dio;

  AuthClient(this.dio);

  Future<Either<ErrorEntity, AuthResponse>> login({required String username, required String password}) async {
    OtelMetrics.authLoginAttempts.add(1);
    try {
      final AuthRequest request = AuthRequest(
        username: username,
        password: password,
      );

      final Response<Map<String, dynamic>> response = await dio.post<Map<String, dynamic>>(
        ServerEndpoints.loginEndpoint,
        data: request.toJson(),
      );

      final AuthResponse auth = AuthResponse.fromJson(response.data!);
      Tracing.currentUserId = Tracing.userIdFromJwt(auth.accessToken);
      return Right(auth);
    } on DioException catch (e) {
      OtelMetrics.authLoginFailures.add(1);
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return Left(ErrorEntity.global('Credenciais inválidas'));
      }

      return Left(ErrorHandler.onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, AuthResponse>> refreshToken() async {
    try {
      final Response<Map<String, dynamic>> response = await dio.post<Map<String, dynamic>>(ServerEndpoints.refreshEndpoint);
      return Right(AuthResponse.fromJson(response.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return Left(ErrorEntity.global('Sessão expirada. Faça login novamente.'));
      }
      return Left(ErrorHandler.onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, void>> logout({
    required String accessToken,
  }) async {
    try {
      await dio.post(
        ServerEndpoints.logoutEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      Tracing.currentUserId = null;
      return Right(null);
    } on DioException catch (e) {
      Tracing.currentUserId = null;
      return Left(ErrorHandler.onRequestError(e));
    }
  }
}
