import 'package:flutter/material.dart';

import 'expandable_fab.dart';

class ExpandableFabItems extends StatelessWidget {
  final String firstHeroTag;
  final String secondHeroTag;
  final String firstRouterName;
  final String secondRouterName;
  final String firstText;
  final String secondText;
  final void Function() updateList;

  const ExpandableFabItems({
    super.key,
    required this.firstHeroTag,
    required this.secondHeroTag,
    required this.firstRouterName,
    required this.secondRouterName,
    required this.firstText,
    required this.secondText,
    required this.updateList
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 100,
      children: [
        Column(
          children: [
            FloatingActionButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(firstRouterName).then((value) {
                if (value == null) {
                  updateList();
                }
              }),
              heroTag: firstHeroTag,
              mini: true,
              shape: const CircleBorder(eccentricity: 0),
              child: const Icon(Icons.person_add_alt_1),
            ),
            Text(firstText)
          ],
        ),
        Column(
          children: [
            FloatingActionButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(secondRouterName).then((value) {
                if (value == null) {
                  updateList();
                }
              }),
              heroTag: secondHeroTag,
              mini: true,
              shape: const CircleBorder(eccentricity: 0),
              child: const Icon(Icons.content_paste)
            ),
            Text(secondText)
          ],
        )
      ]
    );
  }
}
