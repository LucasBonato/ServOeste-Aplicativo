part of 'tecnico_bloc.dart';

@immutable
sealed class TecnicoEvent {}

final class TecnicoSearchOneEvent extends TecnicoEvent {
  final int id;

  TecnicoSearchOneEvent({required this.id});
}

final class TecnicoAvailabilitySearchEvent extends TecnicoEvent {
  final int idEspecialidade;

  TecnicoAvailabilitySearchEvent({
    required this.idEspecialidade,
  });
}

final class TecnicoSearchEvent extends TecnicoEvent {
  final TecnicoFilter filter;
  final int page;
  final int size;

  TecnicoSearchEvent({
    required this.filter,
    this.page = 0,
    this.size = 20,
  });
}

final class TecnicoRegisterEvent extends TecnicoEvent {
  final Tecnico tecnico;
  final String sobrenome;

  TecnicoRegisterEvent({required this.tecnico, required this.sobrenome});
}

final class TecnicoUpdateEvent extends TecnicoEvent {
  final Tecnico tecnico;
  final String sobrenome;

  TecnicoUpdateEvent({required this.tecnico, required this.sobrenome});
}

final class TecnicoDisableListEvent extends TecnicoEvent {
  final List<int> selectedList;

  TecnicoDisableListEvent({required this.selectedList});
}
