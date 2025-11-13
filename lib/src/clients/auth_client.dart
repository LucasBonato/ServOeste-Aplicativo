import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/auth/auth_request.dart';
import 'package:serv_oeste/src/models/auth/auth.dart';
import 'package:serv_oeste/src/utils/error_handler.dart';

class AuthClient {
  final Dio dio;
  final CookieJar cookieJar;

  AuthClient(this.dio, this.cookieJar);

  Future<Either<ErrorEntity, AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final AuthRequest request = AuthRequest(
        username: username,
        password: password,
      );

      final Response<Map<String, dynamic>> response =
          await dio.post<Map<String, dynamic>>(
        ServerEndpoints.loginEndpoint,
        data: request.toJson(),
      );

      return Right(AuthResponse.fromJson(response.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return Left(ErrorEntity(
          id: 20,
          errorMessage: 'Credenciais inválidas',
        ));
      }

      return Left(ErrorHandler.onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, AuthResponse>> refreshToken() async {
    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: ServerEndpoints.baseUrl,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ));

      refreshDio.interceptors.add(CookieManager(cookieJar));

      final Response<Map<String, dynamic>> response =
          await refreshDio.post<Map<String, dynamic>>(
        ServerEndpoints.refreshEndpoint,
        options: Options(
          headers: {
            'content-type': 'application/json',
          },
        ),
      );

      return Right(AuthResponse.fromJson(response.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return Left(ErrorEntity(
          id: 20,
          errorMessage: 'Sessão expirada. Faça login novamente.',
        ));
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
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return Left(ErrorEntity(
          id: 20,
          errorMessage: 'Sessão expirada. Faça login novamente.',
        ));
      }

      return Left(ErrorHandler.onRequestError(e));
    }
  }
}
