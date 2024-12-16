import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';

sealed class ServicoEvent {}

final class ServicoLoadingEvent extends ServicoEvent {
  final ServicoFilterRequest filterRequest;

  ServicoLoadingEvent({required this.filterRequest});
}

final class ServicoSearchOneEvent extends ServicoEvent {
  final int id;

  ServicoSearchOneEvent({required this.id});
}

final class ServicoSearchEvent extends ServicoEvent {
  final ServicoFilterRequest filterRequest;

  ServicoSearchEvent({required this.filterRequest});
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
