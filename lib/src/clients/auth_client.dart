import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/clients/dio/dio_service.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/auth/auth_request.dart';
import 'package:serv_oeste/src/models/auth/register_request.dart';
import 'package:serv_oeste/src/models/auth/auth.dart';
import 'package:serv_oeste/src/models/auth/refresh_token_request.dart';

class AuthClient extends DioService {
  Future<Either<ErrorEntity, AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final AuthRequest request = AuthRequest(
        username: username,
        password: password,
      );

      final Response<dynamic> response = await dio.post(
        ServerEndpoints.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        return Left(ErrorEntity(
          id: 20,
          errorMessage: 'Credenciais inválidas',
        ));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          return Right(
              AuthResponse.fromJson(response.data as Map<String, dynamic>));
        }
      }

      return Left(ErrorEntity(
        id: response.statusCode ?? 500,
        errorMessage: 'Resposta inválida do servidor',
      ));
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, AuthResponse>> register({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final RegisterRequest request = RegisterRequest(
        username: username,
        password: password,
        role: role,
      );

      final Response<dynamic> response = await dio.post(
        ServerEndpoints.registerEndpoint,
        data: request.toJson(),
      );

      return Right(
          AuthResponse.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, AuthResponse>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final RefreshTokenRequest request = RefreshTokenRequest(
        refreshToken: refreshToken,
      );

      final Response<dynamic> response = await dio.post(
        ServerEndpoints.refreshEndpoint,
        data: request.toJson(),
      );

      return Right(
          AuthResponse.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(onRequestError(e));
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
      return Left(onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, bool>> verifyAuth({
    required String accessToken,
  }) async {
    try {
      final Response<dynamic> response = await dio.get(
        ServerEndpoints.authEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return Right(response.statusCode == 200);
    } on DioException catch (e) {
      return Left(onRequestError(e));
    }
  }
}
