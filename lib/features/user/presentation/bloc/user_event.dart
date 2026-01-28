part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class LoadUsersEvent extends UserEvent {
  final int page;
  final int size;

  LoadUsersEvent({
    this.page = 0,
    this.size = 10,
  });
}

class CreateUserEvent extends UserEvent {
  final String username;
  final String password;
  final String role;

  CreateUserEvent({
    required this.username,
    required this.password,
    required this.role,
  });
}

class UpdateUserEvent extends UserEvent {
  final int id;
  final String username;
  final String password;
  final String role;

  UpdateUserEvent({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });
}

class DeleteUserEvent extends UserEvent {
  final String username;

  DeleteUserEvent({required this.username});
}
