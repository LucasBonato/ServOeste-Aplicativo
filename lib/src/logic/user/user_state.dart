part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}

class UserLoadedState extends UserState {
  final List<UserResponse> users;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  UserLoadedState({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });
}

class UserCreatedState extends UserState {}

class UserUpdatedState extends UserState {}

class UserDeletedState extends UserState {}

class UserErrorState extends UserState {
  final ErrorEntity error;

  UserErrorState({required this.error});
}
