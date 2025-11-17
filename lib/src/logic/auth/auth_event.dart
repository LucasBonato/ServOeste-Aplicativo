part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;

  AuthLoginEvent({required this.username, required this.password});
}

final class AuthLogoutEvent extends AuthEvent {}

final class RestoreAuthStateEvent extends AuthEvent {
  final AuthState state;

  RestoreAuthStateEvent({required this.state});
}
