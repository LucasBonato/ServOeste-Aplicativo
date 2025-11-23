import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/clients/user_client.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/src/models/user/user.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserClient _userClient;

  UserBloc(this._userClient) : super(UserInitialState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoadingState());

    final result = await _userClient.findAll(
      page: event.page,
      size: event.size,
    );

    result.fold(
      (error) => emit(UserErrorState(error: error)),
      (users) => emit(UserLoadedState(users: users)),
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserOperationLoadingState());

    final result = await _userClient.register(
      username: event.username,
      password: event.password,
      role: event.role,
    );

    result.fold(
      (error) => emit(UserErrorState(error: error)),
      (_) => emit(UserCreatedState()),
    );
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserOperationLoadingState());

    final result = await _userClient.update(
      id: event.id,
      username: event.username,
      password: event.password,
      role: event.role,
    );

    result.fold(
      (error) => emit(UserErrorState(error: error)),
      (_) => emit(UserUpdatedState()),
    );
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserOperationLoadingState());

    final result = await _userClient.delete(
      username: event.username,
    );

    result.fold(
      (error) => emit(UserErrorState(error: error)),
      (_) => emit(UserDeletedState()),
    );
  }
}
