part of 'lista_bloc.dart';

@immutable
sealed class ListaState {}

final class ListaInitialState extends ListaState {}

final class ListaSelectState extends ListaState {
  final List<int> selectedIds;

  ListaSelectState({
    this.selectedIds = const [],
  });

  bool isItemSelected(int id) => selectedIds.contains(id);

  bool get isSelectionMode => selectedIds.isNotEmpty;

  ListaSelectState copyWith({
    List<int>? selectedIds,
  }) {
    return ListaSelectState(
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
