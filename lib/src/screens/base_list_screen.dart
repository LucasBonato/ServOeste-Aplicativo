import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';

abstract class BaseListScreen<T> extends StatefulWidget {
  const BaseListScreen({super.key});

  @override
  State<BaseListScreen<T>> createState();
}

abstract class BaseListScreenState<T> extends State<BaseListScreen<T>> {
  void onSearchFieldChanged();

  void onDisableItems(List<int> selectedIds);

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

  Widget getUpdateScreen(int id);

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

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}