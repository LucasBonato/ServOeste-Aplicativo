part of 'list_bloc.dart';

sealed class ListState {}

final class ListInitialState extends ListState {}

final class ListSelectState extends ListState {
  final List<int> selectedIds;

  ListSelectState({
    this.selectedIds = const [],
  });

  ListSelectState copyWith({
    List<int>? selectedIds,
  }) {
    return ListSelectState(
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
