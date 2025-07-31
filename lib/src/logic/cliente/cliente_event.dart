part of 'cliente_bloc.dart';

@immutable
sealed class ClienteEvent {}

final class ClienteLoadingEvent extends ClienteEvent {
  final String? nome;
  final String? telefone;
  final String? endereco;
  final int page;
  final int size;

  ClienteLoadingEvent({
    this.nome,
    this.telefone,
    this.endereco,
    this.page = 0,
    this.size = 20,
  });
}

final class ClienteSearchOneEvent extends ClienteEvent {
  final int id;

  ClienteSearchOneEvent({required this.id});
}

final class ClienteSearchEvent extends ClienteEvent {
  final String? nome;
  final String? telefone;
  final String? endereco;

  ClienteSearchEvent({this.nome, this.telefone, this.endereco});
}

final class ClienteSearchMenuEvent extends ClienteEvent {
  final String? nome;
  final String? telefone;
  final String? endereco;

  ClienteSearchMenuEvent({this.nome, this.telefone, this.endereco});
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
