part of 'tecnico_bloc.dart';

@immutable
sealed class TecnicoEvent {}

final class TecnicoLoadingEvent extends TecnicoEvent {
  final int? id;
  final String? nome;
  final String? telefoneFixo;
  final String? telefoneCelular;
  final String? situacao;

  TecnicoLoadingEvent(
      {this.id,
      this.nome,
      this.telefoneFixo,
      this.telefoneCelular,
      this.situacao});
}

final class TecnicoSearchOneEvent extends TecnicoEvent {
  final int id;

  TecnicoSearchOneEvent({required this.id});
}

final class TecnicoSearchEvent extends TecnicoEvent {
  final int? id;
  final String? nome;
  final String? situacao;

  TecnicoSearchEvent({this.id, this.nome, this.situacao});
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

final class TecnicoToggleItemSelectEvent extends TecnicoEvent {
  final int id;

  TecnicoToggleItemSelectEvent({required this.id});
}

final class TecnicoDisableListEvent extends TecnicoEvent {
  final List<int> selectedList;

  TecnicoDisableListEvent({required this.selectedList});
}
