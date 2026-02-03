part of 'servico_bloc.dart';

@immutable
sealed class ServicoEvent {}

final class ServicoSearchOneEvent extends ServicoEvent {
  final int id;

  ServicoSearchOneEvent({required this.id});
}

final class ServicoSearchEvent extends ServicoEvent {
  final ServicoFilter filter;
  final int page;
  final int size;

  ServicoSearchEvent({
    required this.filter,
    this.page = 0,
    this.size = 15,
  });
}

final class ServicoRegisterEvent extends ServicoEvent {
  final ServicoRequest servico;

  ServicoRegisterEvent({required this.servico});
}

final class ServicoRegisterPlusClientEvent extends ServicoEvent {
  final ClienteRequest cliente;
  final ServicoRequest servico;

  ServicoRegisterPlusClientEvent({required this.cliente, required this.servico});
}

final class ServicoUpdateEvent extends ServicoEvent {
  final Servico servico;

  ServicoUpdateEvent({required this.servico});
}

final class ServicoDisableListEvent extends ServicoEvent {
  final List<int> selectedList;

  ServicoDisableListEvent({required this.selectedList});
}
