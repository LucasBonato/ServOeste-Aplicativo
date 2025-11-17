import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/auth/auth.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/services/secure_storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends BaseEntityBloc<AuthEvent, AuthState> {
  final AuthClient _authClient;

  @override
  AuthState loadingState() => AuthLoadingState();

  @override
  AuthState errorState(ErrorEntity error) => AuthErrorState(error: error);

  AuthBloc(this._authClient) : super(AuthInitialState()) {
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
      request: () => _authClient.login(username: event.username, password: event.password),
      onSuccess: (AuthResponse authResponse) async {
        await SecureStorageService.saveTokens(authResponse.accessToken, authResponse.refreshToken);
        emit(AuthLoginSuccessState(authResponse: authResponse));
      }
    );
  }

  Future<void> _logout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await handleRequest<void>(
      emit: emit,
      request: () async {
        final accessToken = await SecureStorageService.getAccessToken();
        final refreshToken = await SecureStorageService.getRefreshToken();

        if (accessToken != null && refreshToken != null) {
          return _authClient.logout(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        return const Right(null);
      },
      onSuccess: (_) async {
        await SecureStorageService.deleteTokens();
        emit(AuthLogoutSuccessState());
      },
      onError: (error) async {
        await SecureStorageService.deleteTokens();
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
