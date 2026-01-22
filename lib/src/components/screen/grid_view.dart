import 'package:flutter/material.dart';

class GridListView extends StatelessWidget {
  final double aspectRatio;
  final List<dynamic> dataList;
  final Widget Function(dynamic data) buildCard;

  const GridListView({
    super.key,
    required this.aspectRatio,
    required this.dataList,
    required this.buildCard,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? screenWidth * 0.02 : 15,
        vertical: 10,
      ),
      child: GridView.builder(
        itemCount: dataList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 1650
              ? 4
              : screenWidth > 1200
                  ? 3
                  : screenWidth > 600
                      ? 2
                      : 1,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          return buildCard(dataList[index]);
        },
      ),
    );
  }
}
