import 'package:flutter/material.dart';
import 'expandable_fab.dart';

class ExpandableFabItems extends StatelessWidget {
  final String firstHeroTag;
  final String secondHeroTag;
  final String firstRouterName;
  final String secondRouterName;
  final String firstTooltip;
  final String secondTooltip;
  final void Function() updateList;

  const ExpandableFabItems({
    super.key,
    required this.firstHeroTag,
    required this.secondHeroTag,
    required this.firstRouterName,
    required this.secondRouterName,
    required this.firstTooltip,
    required this.secondTooltip,
    required this.updateList,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 100,
      children: [
        FloatingActionButton(
          onPressed: () => Navigator.of(context, rootNavigator: true)
              .pushNamed(firstRouterName)
              .then((value) {
            if (value == null) {
              updateList();
            }
          }),
          heroTag: firstHeroTag,
          mini: true,
          shape: const CircleBorder(),
          tooltip: firstTooltip,
        ),
        FloatingActionButton(
          onPressed: () => Navigator.of(context, rootNavigator: true)
              .pushNamed(secondRouterName)
              .then((value) {
            if (value == null) {
              updateList();
            }
          }),
          heroTag: secondHeroTag,
          mini: true,
          shape: const CircleBorder(),
          tooltip: secondTooltip,
        ),
      ],
    );
  }
}
