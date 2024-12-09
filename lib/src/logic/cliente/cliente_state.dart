part of 'cliente_bloc.dart';

@immutable
sealed class ClienteState {}

final class ClienteInitialState extends ClienteState {}

final class ClienteLoadingState extends ClienteState {}

final class ClienteSearchOneSuccessState extends ClienteState {
  final Cliente cliente;

  ClienteSearchOneSuccessState({required this.cliente});
}

final class ClienteSearchSuccessState extends ClienteState {
  final List<Cliente> clientes;

  ClienteSearchSuccessState({required this.clientes});
}

final class ClienteRegisterSuccessState extends ClienteState {}

final class ClienteUpdateSuccessState extends ClienteState {}

final class ClienteListState extends ClienteState {
  final List<Cliente> clientes;
  final List<int> selectedIds;

  ClienteListState({
    required this.clientes,
    this.selectedIds = const [],
  });
}

final class ClienteErrorState extends ClienteState {
  final ErrorEntity error;

  ClienteErrorState({required this.error});
}
