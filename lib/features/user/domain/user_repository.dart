import 'package:dartz/dartz.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/src/models/user/user_response.dart';

abstract class UserRepository {
  Future<Either<ErrorEntity, PageContent<UserResponse>>> findAll({
    int page = 0,
    int size = 10,
  });
  Future<Either<ErrorEntity, void>> register({
    required String username,
    required String password,
    required String role,
  });
  Future<Either<ErrorEntity, void>> update({
    required int id,
    required String username,
    required String password,
    required String role,
  });
  Future<Either<ErrorEntity, void>> delete(String username);
}
