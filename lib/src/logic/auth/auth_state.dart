part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthLoginSuccessState extends AuthState {
  final AuthResponse authResponse;

  AuthLoginSuccessState({required this.authResponse});
}

final class UnauthenticatedState extends AuthState {}

final class AuthLogoutSuccessState extends AuthState {}

final class AuthErrorState extends AuthState {
  final ErrorEntity error;

  AuthErrorState({required this.error});
}
