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

final class ClienteDeleteListEvent extends ClienteEvent {
  final List<int> selectedList;

  ClienteDeleteListEvent({
    required this.selectedList
  });
}

final class ClienteToggleItemSelectEvent extends ClienteEvent {
  final int id;

  ClienteToggleItemSelectEvent({
    required this.id
  });
}