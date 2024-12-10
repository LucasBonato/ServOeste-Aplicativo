import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc() : super(ListInitialState()) {
    on<ListInitialEvent>(_onInitialEvent);
    on<ListToggleItemSelectEvent>(_onToggleItemsSelect);
    on<ListClearSelectionEvent>(_onClearSelection);
  }

  void _onInitialEvent(ListInitialEvent event, Emitter<ListState> emit) {
    emit(ListSelectState(selectedIds: []));
  }

  void _onToggleItemsSelect(
      ListToggleItemSelectEvent event, Emitter<ListState> emit) {
    if (state is ListSelectState) {
      final currentState = state as ListSelectState;
      List<int> updatedSelectedIds = List.from(currentState.selectedIds);

      if (updatedSelectedIds.contains(event.id)) {
        updatedSelectedIds.remove(event.id);
      } else {
        updatedSelectedIds.add(event.id);
      }

      emit(ListSelectState(
        selectedIds: updatedSelectedIds,
      ));
    }
  }

  void _onClearSelection(
      ListClearSelectionEvent event, Emitter<ListState> emit) {
    if (state is ListSelectState) {
      final currentState = state as ListSelectState;
      emit(currentState.copyWith(selectedIds: []));
    }
  }
}
