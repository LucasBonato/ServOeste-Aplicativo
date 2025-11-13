part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserOperationLoading extends UserState {}

class UserLoaded extends UserState {
  final PageContent<User> users;

  UserLoaded({required this.users});
}

class UserCreated extends UserState {}

class UserUpdated extends UserState {}

class UserDeleted extends UserState {}

class UserError extends UserState {
  final ErrorEntity error;

  UserError({required this.error});
}
