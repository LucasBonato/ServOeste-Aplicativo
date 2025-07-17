import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/screen/grid_view.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';

abstract class BaseListScreen<T> extends StatefulWidget {
  const BaseListScreen({super.key});

  @override
  State<BaseListScreen<T>> createState();
}

abstract class BaseListScreenState<T> extends State<BaseListScreen<T>> {
  final Debouncer debouncer = Debouncer();

  void searchFieldChanged();

  void onDisableItems(List<int> selectedIds);

  Widget getUpdateScreen(int id);

  Widget buildDefaultFloatingActionButton();

  Widget buildSelectionFloatingActionButton(List<int> selectedIds);

  Widget buildItemCard(T item, bool isSelected, bool isSelectMode);

  void onSearchFieldChanged() {
    debouncer.execute(searchFieldChanged);
  }

  void onNavigateToUpdateScreen(int id) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => getUpdateScreen(id),
      ),
    );
    context.read<ListaBloc>().add(ListaClearSelectionEvent());
  }

  void onSelectItemList(int id) {
    context.read<ListaBloc>().add(ListaToggleItemSelectEvent(id: id));
  }

  void disableSelectedItems(BuildContext context, List<int> selectedIds) {
    onDisableItems(selectedIds);
    context.read<ListaBloc>().add(ListaClearSelectionEvent());
  }

  bool isSelectionMode(ListaState stateLista) {
    return (stateLista is ListaSelectState)
        ? stateLista.selectedIds.isNotEmpty
        : false;
  }

  bool isItemSelected(int id, ListaState listState) {
    return (listState is ListaSelectState)
        ? listState.selectedIds.contains(id)
        : false;
  }

  Widget buildFloatingActionButton() {
    return BlocBuilder<ListaBloc, ListaState>(
        builder: (context, state) {
          final bool hasSelection = state is ListaSelectState && state.selectedIds.isNotEmpty;

          return !hasSelection
              ? buildDefaultFloatingActionButton()
              : buildSelectionFloatingActionButton(state.selectedIds);
        },
    );
  }

  Widget buildGridOfCards(List<T> items, double aspectRatio) {
    return SingleChildScrollView(
      child: GridListView(
        aspectRatio: aspectRatio,
        dataList: items,
        buildCard: (item) => BlocBuilder<ListaBloc, ListaState>(
          builder: (context, stateLista) {
            final bool isSelected = isItemSelected(item.id, stateLista);
            final bool isSelectMode = isSelectionMode(stateLista);

            return buildItemCard(item, isSelected, isSelectMode);
          },
        ),
      ),
    );
  }
}