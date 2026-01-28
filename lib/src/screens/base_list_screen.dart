import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/layout/pagination_widget.dart';
import 'package:serv_oeste/src/components/screen/entity_not_found.dart';
import 'package:serv_oeste/src/components/screen/grid_view.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/models/enums/list_style.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';

abstract class BaseListScreen<T> extends StatefulWidget {
  const BaseListScreen({super.key});
}

abstract class BaseListScreenState<T> extends State<BaseListScreen<T>> {
  final Debouncer _debouncer = Debouncer();
  ListStyle _listStyle = ListStyle.grid;

  void searchFieldChanged();

  void onDisableItems(List<int> selectedIds);

  Widget? getCreateScreen() => null;

  Widget getUpdateScreen(int id, {int? secondId});

  Widget buildDefaultFloatingActionButton();

  Widget buildSelectionFloatingActionButton(List<int> selectedIds);

  Widget buildItemCard(T item, bool isSelected, bool isSelectMode, bool isSkeleton);

  void setListStyle(ListStyle listStyle) {
    _listStyle = listStyle;
  }

  void onSearchFieldChanged() {
    _debouncer.execute(searchFieldChanged);
  }

  void onNavigateToUpdateScreen(int id, VoidCallback onSuccess, {int? secondId}) {
    Navigator.of(context, rootNavigator: true)
        .push(
          MaterialPageRoute(
            builder: (context) => getUpdateScreen(id, secondId: secondId),
          ),
        )
        .then((value) {
          if (value == true && mounted) {
            onSuccess();
          }
        });
    context.read<ListaBloc>().add(ListaClearSelectionEvent());
  }

  void onNavigateToCreateScreen(int id, VoidCallback onSuccess, {int? secondId}) {
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => getCreateScreen()!,
      ),
    )
        .then((value) {
      if (value == true && mounted) {
        onSuccess();
      }
    });
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
    return (stateLista is ListaSelectState) ? stateLista.selectedIds.isNotEmpty : false;
  }

  bool isItemSelected(int id, ListaState listState) {
    return (listState is ListaSelectState) ? listState.selectedIds.contains(id) : false;
  }

  Widget buildFloatingActionButton() {
    return BlocBuilder<ListaBloc, ListaState>(
      builder: (context, state) {
        final bool hasSelection = state is ListaSelectState && state.selectedIds.isNotEmpty;

        return !hasSelection ? buildDefaultFloatingActionButton() : buildSelectionFloatingActionButton(state.selectedIds);
      },
    );
  }

  Widget buildGridOfCards({
    required List<T> items,
    required double aspectRatio,
    required int totalPages,
    required int currentPage,
    required Function(int) onPageChanged,
    bool isSkeleton = false,
    SliverGridDelegate? gridDelegate,
    double mainAxisSpacing = 15,
    double crossAxisSpacing = 15,
    double horizontalPadding = 15,
    double verticalPadding = 10,
  }) {
    if (items.isEmpty) {
      return const EntityNotFound(message: "Nenhum item encontrado.");
    }

    if (_listStyle == ListStyle.list) {
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => buildItemCard(items[index], false, false, isSkeleton),
      );
    }

    final gridContent = GridListView(
      aspectRatio: aspectRatio,
      dataList: items,
      gridDelegate: gridDelegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      buildCard: (item) => BlocBuilder<ListaBloc, ListaState>(
        builder: (context, stateLista) {
          final bool isSelected = isSkeleton ? false : isItemSelected(item.id, stateLista);
          final bool isSelectMode = isSkeleton ? false : isSelectionMode(stateLista);

          return buildItemCard(item, isSelected, isSelectMode, isSkeleton);
        },
      ),
    );

    if (totalPages <= 1) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            gridContent,
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          gridContent,
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 40,
              left: 16,
              right: 16,
            ),
            child: PaginationWidget(
              currentPage: currentPage + 1,
              totalPages: totalPages,
              onPageChanged: onPageChanged,
            ),
          ),
        ],
      ),
    );
  }
}
