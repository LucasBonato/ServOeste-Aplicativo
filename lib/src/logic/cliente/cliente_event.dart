part of 'cliente_bloc.dart';

@immutable
sealed class ClienteEvent {}

final class ClienteLoadingEvent extends ClienteEvent {
  final String? nome;
  final String? telefone;
  final String? endereco;

  ClienteLoadingEvent({
    this.nome,
    this.telefone,
    this.endereco
  });
}

final class ClienteSearchOneEvent extends ClienteEvent {
  final int id;

  ClienteSearchOneEvent({
    required this.id
  });
}

final class ClienteSearchEvent extends ClienteEvent {
  final String? nome;
  final String? telefone;
  final String? endereco;

  ClienteSearchEvent({
    this.nome,
    this.telefone,
    this.endereco
  });
}

final class ClienteRegisterEvent extends ClienteEvent {
  final Cliente cliente;
  final String sobrenome;

  ClienteRegisterEvent({
    required this.cliente,
    required this.sobrenome
  });
}

final class ClienteUpdateEvent extends ClienteEvent {
  final Cliente cliente;
  final String sobrenome;

  ClienteUpdateEvent({
    required this.cliente,
    required this.sobrenome
  });
}

final class ClienteDeleteListEvent extends ClienteEvent {
  final List<int> selectedList;

  ClienteDeleteListEvent({
    required this.selectedList
  });
}

// TODO - Fazer o toggle dos items através de eventos (BloC)
final class ClienteToggleItemSelectEvent extends ClienteEvent {
  final int id;

  ClienteToggleItemSelectEvent({
    required this.id
  });
}