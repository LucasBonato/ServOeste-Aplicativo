import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/core/http/server_endpoints.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth_request.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/utils/error_handler.dart';

class AuthClient {
  final Dio dio;

  AuthClient(this.dio);

  Future<Either<ErrorEntity, AuthResponse>> login({required String username, required String password}) async {
    try {
      final AuthRequest request = AuthRequest(
        username: username,
        password: password,
      );

      final Response<Map<String, dynamic>> response = await dio.post<Map<String, dynamic>>(
        ServerEndpoints.loginEndpoint,
        data: request.toJson(),
      );

      return Right(AuthResponse.fromJson(response.data!));
    } on DioException catch (e) {
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
    required String refreshToken,
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

      return Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
  }
}
