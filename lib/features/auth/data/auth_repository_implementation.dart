import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/auth/data/auth_client.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/src/models/auth/auth.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthClient _client;

  AuthRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, AuthResponse>> login({required String username, required String password}) {
    return _client.login(username: username, password: password);
  }

  @override
  Future<Either<ErrorEntity, void>> logout({required String accessToken, required String refreshToken}) {
    return _client.logout(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<Either<ErrorEntity, AuthResponse>> refreshToken() {
    return _client.refreshToken();
  }
}
