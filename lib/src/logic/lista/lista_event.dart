part of 'lista_bloc.dart';

@immutable
sealed class ListaEvent {}

final class ListaInitialEvent extends ListaEvent {}

final class ListaClearSelectionEvent extends ListaEvent {}

final class ListaToggleItemSelectEvent extends ListaEvent {
  final int id;

  ListaToggleItemSelectEvent({
    required this.id,
  });
}
