part of 'cliente_bloc.dart';

@immutable
sealed class ClienteEvent {}

final class ClienteSearchOneEvent extends ClienteEvent {
  final int id;

  ClienteSearchOneEvent({required this.id});
}

final class ClienteSearchEvent extends ClienteEvent {
  final ClienteFilter filter;
  final int page;
  final int size;

  ClienteSearchEvent({
    required this.filter,
    this.page = 0,
    this.size = 24,
  });
}

final class RestoreClienteStateEvent extends ClienteEvent {
  final ClienteState state;

  RestoreClienteStateEvent({required this.state});
}

final class ClienteRegisterEvent extends ClienteEvent {
  final Cliente cliente;
  final String sobrenome;

  ClienteRegisterEvent({required this.cliente, required this.sobrenome});
}

final class ClienteUpdateEvent extends ClienteEvent {
  final Cliente cliente;
  final String sobrenome;

  ClienteUpdateEvent({required this.cliente, required this.sobrenome});
}

final class ClienteDeleteListEvent extends ClienteEvent {
  final List<int> selectedList;

  ClienteDeleteListEvent({required this.selectedList});
}
