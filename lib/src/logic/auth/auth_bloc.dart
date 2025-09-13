import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/auth/auth.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/clients/auth_client.dart';
import 'package:serv_oeste/src/services/secure_storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends BaseEntityBloc<AuthEvent, AuthState> {
  final AuthClient _authClient;
  bool _hasCheckedInitialStatus = false;

  @override
  AuthState loadingState() => AuthLoadingState();

  @override
  AuthState errorState(ErrorEntity error) => AuthErrorState(error: error);

  AuthBloc(this._authClient) : super(AuthInitialState()) {
    on<AuthCheckStatusEvent>(_checkStatus);
    on<AuthLoginEvent>(_login);
    on<AuthRegisterEvent>(_register);
    on<AuthLogoutEvent>(_logout);
    on<RestoreAuthStateEvent>(_restoreState);

    if (!_hasCheckedInitialStatus) {
      _hasCheckedInitialStatus = true;
      add(AuthCheckStatusEvent());
    }
  }

  Future<void> _checkStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final token = await SecureStorageService.getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      if (isLoggedIn) {
        emit(AuthenticatedState());
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(errorState(ErrorEntity(
        id: 0,
        errorMessage: 'Erro ao verificar status de autenticação: $e',
      )));
    }
  }

  Future<void> _login(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await _authClient.login(
        username: event.username,
        password: event.password,
      );

      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => null)!;
        emit(errorState(error));
      } else {
        final authResponse = result.fold((l) => null, (r) => r)!;
        await SecureStorageService.saveTokens(
            authResponse.accessToken, authResponse.refreshToken);
        emit(AuthLoginSuccessState(authResponse: authResponse));
      }
    } catch (e) {
      emit(errorState(ErrorEntity(
        id: 0,
        errorMessage: 'Erro inesperado no login: $e',
      )));
    }
  }

  Future<void> _register(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await _authClient.register(
        username: event.username,
        password: event.password,
        role: event.role,
      );

      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => null)!;
        emit(errorState(error));
      } else {
        emit(AuthRegisterSuccessState());
      }
    } catch (e) {
      emit(errorState(ErrorEntity(
        id: 0,
        errorMessage: 'Erro inesperado no registro: $e',
      )));
    }
  }

  Future<void> _logout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final accessToken = await SecureStorageService.getAccessToken();
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (accessToken != null && refreshToken != null) {
        await _authClient.logout(
            accessToken: accessToken, refreshToken: refreshToken);
      }

      await SecureStorageService.deleteTokens();
      emit(AuthLogoutSuccessState());
    } catch (e) {
      emit(errorState(ErrorEntity(
        id: 0,
        errorMessage: 'Erro ao fazer logout: $e',
      )));
      await SecureStorageService.deleteTokens();
    }
  }

  Future<void> _restoreState(
    RestoreAuthStateEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(event.state);
  }

  Future<bool> isAuthenticated() async {
    final token = await SecureStorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getCurrentToken() async {
    return await SecureStorageService.getAccessToken();
  }
}
