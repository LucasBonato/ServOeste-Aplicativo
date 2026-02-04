import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/features/user/domain/entities/user_response.dart';
import 'package:serv_oeste/features/user/domain/user_repository.dart';
import 'package:serv_oeste/shared/bloc/base_entity_bloc.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends BaseEntityBloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  @override
  UserState loadingState() => UserLoadingState();

  @override
  UserState errorState(ErrorEntity error) => UserErrorState(error: error);

  UserBloc(this._userRepository) : super(UserInitialState()) {
    on<LoadUsersEvent>(_fetchAllUsers);
    on<CreateUserEvent>(_onRegisterUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _fetchAllUsers(LoadUsersEvent event, Emitter<UserState> emit) async {
    await handleRequest<PageContent<UserResponse>>(
      emit: emit,
      request: () => _userRepository.findAll(
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<UserResponse> pageUsers) => emit(UserLoadedState(
        users: pageUsers.content,
        currentPage: pageUsers.page.page,
        totalPages: pageUsers.page.totalPages,
        totalElements: pageUsers.page.totalElements,
      )),
    );
  }

  Future<void> _onRegisterUser(CreateUserEvent event, Emitter<UserState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _userRepository.register(
        username: event.username,
        password: event.password,
        role: event.role,
      ),
      onSuccess: (_) => emit(UserCreatedState()),
    );
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _userRepository.update(
        id: event.id,
        username: event.username,
        password: event.password,
        role: event.role,
      ),
      onSuccess: (_) => emit(UserUpdatedState()),
    );
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<UserState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _userRepository.delete(event.username),
      onSuccess: (_) => emit(UserDeletedState()),
    );
  }
}
