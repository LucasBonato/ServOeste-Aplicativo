import 'package:dartz/dartz.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

abstract class AuthRepository {
  Future<Either<ErrorEntity, AuthResponse>> login({required String username, required String password});

  Future<Either<ErrorEntity, AuthResponse>> refreshToken();

  Future<Either<ErrorEntity, void>> logout({required String accessToken, required String refreshToken});
}
