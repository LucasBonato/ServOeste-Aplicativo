import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/user/data/user_client.dart';
import 'package:serv_oeste/features/user/domain/user_repository.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/src/models/user/user_response.dart';

class UserRepositoryImplementation implements UserRepository {
  final UserClient _client;

  UserRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, void>> delete(String username) async {
    return await _client.delete(username: username);
  }

  @override
  Future<Either<ErrorEntity, PageContent<UserResponse>>> findAll({int page = 0, int size = 10}) async {
    return await _client.findAll(page: page, size: size);
  }

  @override
  Future<Either<ErrorEntity, void>> register({required String username, required String password, required String role}) async {
    return await _client.register(username: username, password: password, role: role);
  }

  @override
  Future<Either<ErrorEntity, void>> update({required int id, required String username, required String password, required String role}) async {
    return await _client.update(id: id, username: username, password: password, role: role);
  }
}
