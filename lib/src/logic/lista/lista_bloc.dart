import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'lista_event.dart';

part 'lista_state.dart';

class ListaBloc extends Bloc<ListaEvent, ListaState> {
  ListaBloc() : super(ListaInitialState()) {
    on<ListaInitialEvent>(_onInitialEvent);
    on<ListaToggleItemSelectEvent>(_onToggleItemsSelect);
    on<ListaClearSelectionEvent>(_onClearSelection);
  }

  void _onInitialEvent(ListaInitialEvent event, Emitter<ListaState> emit) {
    emit(ListaSelectState(selectedIds: []));
  }

  void _onToggleItemsSelect(ListaToggleItemSelectEvent event, Emitter<ListaState> emit) {
    if (state is ListaSelectState) {
      final currentState = state as ListaSelectState;
      final updatedSelectedIds = List<int>.from(currentState.selectedIds);

      updatedSelectedIds.contains(event.id)
          ? updatedSelectedIds.remove(event.id)
          : updatedSelectedIds.add(event.id);

      emit(ListaSelectState(selectedIds: updatedSelectedIds));
    }
  }

  void _onClearSelection(ListaClearSelectionEvent event, Emitter<ListaState> emit) {
    if (state is ListaSelectState) {
      final currentState = state as ListaSelectState;
      emit(currentState.copyWith(selectedIds: []));
    }
  }
}
