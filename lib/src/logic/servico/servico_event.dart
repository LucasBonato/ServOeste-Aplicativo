part of 'servico_bloc.dart';

@immutable
sealed class ServicoEvent {}

final class ServicoLoadingEvent extends ServicoEvent {
  final ServicoFilterRequest filterRequest;
  final int page;
  final int size;

  ServicoLoadingEvent({
    required this.filterRequest,
    this.page = 0,
    this.size = 15,
  });
}

final class ServicoInitialLoadingEvent extends ServicoEvent {
  final ServicoFilterRequest filterRequest;
  final int page;
  final int size;

  ServicoInitialLoadingEvent({
    required this.filterRequest,
    this.page = 0,
    this.size = 15,
  });
}

final class ServicoSearchMenuEvent extends ServicoEvent {
  final ServicoFilterRequest? filterRequest;
  final int page;
  final int size;

  ServicoSearchMenuEvent({
    this.filterRequest,
    this.page = 0,
    this.size = 15,
  });
}

final class ServicoSearchOneEvent extends ServicoEvent {
  final int id;

  ServicoSearchOneEvent({required this.id});
}

final class ServicoRegisterEvent extends ServicoEvent {
  final ServicoRequest servico;

  ServicoRegisterEvent({required this.servico});
}

final class ServicoRegisterPlusClientEvent extends ServicoEvent {
  final ClienteRequest cliente;
  final ServicoRequest servico;

  ServicoRegisterPlusClientEvent(
      {required this.cliente, required this.servico});
}

final class ServicoUpdateEvent extends ServicoEvent {
  final Servico servico;

  ServicoUpdateEvent({required this.servico});
}

final class ServicoDisableListEvent extends ServicoEvent {
  final List<int> selectedList;

  ServicoDisableListEvent({required this.selectedList});
}
