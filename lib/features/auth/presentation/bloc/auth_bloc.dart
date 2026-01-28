import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/core/services/secure_storage_service.dart';
import 'package:serv_oeste/features/auth/domain/auth_repository.dart';
import 'package:serv_oeste/shared/bloc/base_entity_bloc.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends BaseEntityBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _storage;

  @override
  AuthState loadingState() => AuthLoadingState();

  @override
  AuthState errorState(ErrorEntity error) => AuthErrorState(error: error);

  AuthBloc(this._authRepository, this._storage) : super(AuthInitialState()) {
    on<AuthLoginEvent>(_login);
    on<AuthLogoutEvent>(_logout);
    on<RestoreAuthStateEvent>(_restoreState);
  }

  Future<void> _login(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    await handleRequest<AuthResponse>(
      emit: emit,
      request: () => _authRepository.login(username: event.username, password: event.password),
      onSuccess: (AuthResponse authResponse) async {
        await _storage.saveTokens(authResponse.accessToken, authResponse.refreshToken);
        emit(AuthLoginSuccessState(authResponse: authResponse));
      },
    );
  }

  Future<void> _logout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await handleRequest<void>(
      emit: emit,
      request: () async {
        final String? accessToken = await _storage.getAccessToken();
        final String? refreshToken = await _storage.getRefreshToken();

        if (accessToken != null && refreshToken != null) {
          return _authRepository.logout(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        return const Right(null);
      },
      onSuccess: (_) async {
        await _storage.deleteTokens();
        emit(AuthLogoutSuccessState());
      },
      onError: (error) async {
        await _storage.deleteTokens();
        emit(errorState(error));
      },
    );
  }

  Future<void> _restoreState(
    RestoreAuthStateEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(event.state);
  }
}
