part of 'list_bloc.dart';

@immutable
sealed class ListEvent {}

final class ListInitialEvent extends ListEvent {}

final class ListClearSelectionEvent extends ListEvent {}

final class ListToggleItemSelectEvent extends ListEvent {
  final int id;

  ListToggleItemSelectEvent({
    required this.id,
  });
}
