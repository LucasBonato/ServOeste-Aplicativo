part of 'list_bloc.dart';

@immutable
sealed class ListState {}

final class ListInitialState extends ListState {}

final class ListSelectState extends ListState {
  final List<int> selectedIds;

  ListSelectState({
    this.selectedIds = const [],
  });
}
