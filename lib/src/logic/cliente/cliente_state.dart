part of 'cliente_bloc.dart';

@immutable
sealed class ClienteState {}

final class ClienteInitialState extends ClienteState {}

final class ClienteLoadingState extends ClienteState {}

final class ClienteSuccessState extends ClienteState {
  final List<Cliente> clientes;

  ClienteSuccessState({
    required this.clientes
  });
}

final class ClienteErrorState extends ClienteState {
  final ErrorEntity error;

  ClienteErrorState({
    required this.error
  });
}