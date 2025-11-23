part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}

class UserOperationLoadingState extends UserState {}

class UserLoadedState extends UserState {
  final PageContent<User> users;

  UserLoadedState({required this.users});
}

class UserCreatedState extends UserState {}

class UserUpdatedState extends UserState {}

class UserDeletedState extends UserState {}

class UserErrorState extends UserState {
  final ErrorEntity error;

  UserErrorState({required this.error});
}
