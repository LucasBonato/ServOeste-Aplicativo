part of 'tecnico_bloc.dart';

@immutable
sealed class TecnicoEvent {}

final class TecnicoLoadingEvent extends TecnicoEvent {
  final int? id;
  final String? nome;
  final String? situacao;

  TecnicoLoadingEvent({
    this.id,
    this.nome,
    this.situacao
  });
}

final class TecnicoSearchOneEvent extends TecnicoEvent {}

final class TecnicoSearchEvent extends TecnicoEvent {
  final int? id;
  final String? nome;
  final String? situacao;

  TecnicoSearchEvent({
    this.id,
    this.nome,
    this.situacao
  });
}

final class TecnicoRegisterEvent extends TecnicoEvent {}

final class TecnicoUpdateEvent extends TecnicoEvent {}

final class TecnicoDisableListEvent extends TecnicoEvent {
  final List<int> selectedList;

  TecnicoDisableListEvent({
    required this.selectedList
  });
}