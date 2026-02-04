part of 'cliente_bloc.dart';

@immutable
sealed class ClienteState {}

final class ClienteInitialState extends ClienteState {}

final class ClienteLoadingState extends ClienteState {}

final class ClienteSearchOneLoadingState extends ClienteLoadingState {}

final class ClienteSearchOneSuccessState extends ClienteState {
  final Cliente cliente;

  ClienteSearchOneSuccessState({required this.cliente});
}

final class ClienteSearchSuccessState extends ClienteState {
  final List<Cliente> clientes;
  final ClienteFilter filter;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  ClienteSearchSuccessState({
    required this.clientes,
    required this.filter,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });
}

final class ClienteRegisterSuccessState extends ClienteState {}

final class ClienteUpdateSuccessState extends ClienteState {}

final class ClienteErrorState extends ClienteState {
  final ErrorEntity error;
  final List<Cliente>? clientes;

  ClienteErrorState({required this.error, this.clientes});
}
