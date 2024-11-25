import 'package:flutter/material.dart';

class GridListView extends StatelessWidget {
  final List<dynamic> dataList;
  final Widget Function(dynamic data) buildCard;

  const GridListView({
    super.key,
    required this.dataList,
    required this.buildCard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600
            ? MediaQuery.of(context).size.width * 0.02
            : 30,
        vertical: 10,
      ),
      child: GridView.builder(
        itemCount: dataList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1650
              ? 4
              : MediaQuery.of(context).size.width > 1200
                  ? 3
                  : MediaQuery.of(context).size.width > 600
                      ? 2
                      : 1,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          return buildCard(dataList[index]);
        },
      ),
    );
  }
}
