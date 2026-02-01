import 'package:flutter/material.dart';

import 'expandable_fab.dart';

class ExpandableFabItems extends StatelessWidget {
  final String firstHeroTag;
  final String firstRouterName;
  final String firstTooltip;
  final Widget firstChild;
  final Object? firstArgs;
  final String secondHeroTag;
  final String secondRouterName;
  final String secondTooltip;
  final Widget secondChild;
  final Object? secondArgs;
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
    this.firstArgs,
    this.secondArgs,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 100,
      children: [
        FloatingActionButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(firstRouterName, arguments: firstArgs).then((value) {
            if (value == true) {
              updateList();
            }
          }),
          heroTag: firstHeroTag,
          backgroundColor: Color(0xFF007BFF),
          shape: const CircleBorder(),
          tooltip: firstTooltip,
          child: firstChild,
        ),
        FloatingActionButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(secondRouterName, arguments: secondArgs).then((value) {
            if (value == true) {
              updateList();
            }
          }),
          heroTag: secondHeroTag,
          shape: const CircleBorder(),
          tooltip: secondTooltip,
          backgroundColor: Color(0xFF007BFF),
          child: secondChild,
        ),
      ],
    );
  }
}
