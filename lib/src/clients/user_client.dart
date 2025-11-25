import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/src/clients/dio/server_endpoints.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/src/models/user/user_response.dart';
import 'package:serv_oeste/src/utils/error_handler.dart';

class UserClient {
  final Dio dio;

  UserClient(this.dio);

  Future<Either<ErrorEntity, PageContent<UserResponse>>> findAll({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        ServerEndpoints.userEndpoint,
        queryParameters: {
          "page": page,
          "size": size,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return Right(PageContent.fromJson(response.data, (json) => UserResponse.fromJson(json)));
      }
      return Right(PageContent.empty());
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, void>> register({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      await dio.post(
        ServerEndpoints.userEndpoint,
        data: {
          'username': username,
          'password': password,
          'role': role,
        },
      );
      return Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, void>> update({
    required int id,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      await dio.put(
        ServerEndpoints.userEndpoint,
        data: {
          'id': id,
          'username': username,
          'password': password,
          'role': role,
        },
      );
      return Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
  }

  Future<Either<ErrorEntity, void>> delete({
    required String username,
  }) async {
    try {
      await dio.delete(
        ServerEndpoints.userEndpoint,
        queryParameters: {'username': username},
      );
      return Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.onRequestError(e));
    }
  }
}
