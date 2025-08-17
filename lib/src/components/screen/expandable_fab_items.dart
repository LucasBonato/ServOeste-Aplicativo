import 'package:flutter/material.dart';
import 'expandable_fab.dart';

class ExpandableFabItems extends StatelessWidget {
  final String firstHeroTag;
  final String secondHeroTag;
  final String firstRouterName;
  final String secondRouterName;
  final String firstTooltip;
  final String secondTooltip;
  final Widget firstChild;
  final Widget secondChild;
  final void Function() updateList;

  const ExpandableFabItems({
    super.key,
    required this.firstHeroTag,
    required this.secondHeroTag,
    required this.firstRouterName,
    required this.secondRouterName,
    required this.firstTooltip,
    required this.secondTooltip,
    required this.firstChild,
    required this.secondChild,
    required this.updateList,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 100,
      children: [
        FloatingActionButton(
          onPressed: () =>
              Navigator.of(context, rootNavigator: true)
                  .pushNamed(firstRouterName, arguments: {"isClientAndService": false})
                  .then((value) {
                    if (value == true) {
                      updateList();
                    }
                  }),
          heroTag: firstHeroTag,
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          tooltip: firstTooltip,
          child: firstChild,
        ),
        FloatingActionButton(
          onPressed: () =>
              Navigator.of(context, rootNavigator: true)
                  .pushNamed(secondRouterName)
                  .then((value) {
                    if (value == true) {
                      updateList();
                    }
                  }),
          heroTag: secondHeroTag,
          shape: const CircleBorder(),
          tooltip: secondTooltip,
          backgroundColor: Colors.blue,
          child: secondChild,
        ),
      ],
    );
  }
}
