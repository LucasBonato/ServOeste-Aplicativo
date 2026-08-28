import 'package:dartz/dartz.dart';
import 'package:serv_oeste/core/observability/tracing.dart';
import 'package:serv_oeste/features/auth/data/auth_client.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthClient _client;

  AuthRepositoryImplementation(this._client);

  @override
  Future<Either<ErrorEntity, AuthResponse>> login({required String username, required String password}) {
    return Tracing.trace(
      'auth.login',
      attributes: {'auth.username': username},
      fn: () => _client.login(username: username, password: password),
    );
  }

  @override
  Future<Either<ErrorEntity, void>> logout({required String accessToken}) {
    return Tracing.trace(
      'auth.logout',
      fn: () => _client.logout(accessToken: accessToken),
    );
  }

  @override
  Future<Either<ErrorEntity, AuthResponse>> refreshToken() {
    return Tracing.trace(
      'auth.refresh_token',
      fn: () => _client.refreshToken(),
    );
  }
}
