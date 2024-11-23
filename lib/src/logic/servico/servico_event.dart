part of 'servico_bloc.dart';

@immutable
sealed class ServicoEvent {}

final class ServicoLoadingEvent extends ServicoEvent {
  final ServicoFilterRequest filterRequest;

  ServicoLoadingEvent({
    required this.filterRequest
  });
}

final class ServicoSearchOneEvent extends ServicoEvent {}

final class ServicoSearchEvent extends ServicoEvent {}

final class ServicoRegisterEvent extends ServicoEvent {}

final class ServicoRegisterPlusClientEvent extends ServicoEvent {
  final ClienteRequest cliente;
  final ServicoRequest servico;

  ServicoRegisterPlusClientEvent({
    required this.cliente,
    required this.servico
  });
}

final class ServicoUpdateEvent extends ServicoEvent {}

final class ServicoDeleteEvent extends ServicoEvent {}