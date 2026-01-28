import 'package:flutter/material.dart';

class GridListView extends StatelessWidget {
  final double aspectRatio;
  final List<dynamic> dataList;
  final Widget Function(dynamic data) buildCard;
  final SliverGridDelegate? gridDelegate;
  final double horizontalPadding;
  final double verticalPadding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const GridListView({
    super.key,
    required this.aspectRatio,
    required this.dataList,
    required this.buildCard,
    this.gridDelegate,
    this.horizontalPadding = 15,
    this.verticalPadding = 10,
    this.mainAxisSpacing = 15,
    this.crossAxisSpacing = 15,
  });

  SliverGridDelegate _buildDefaultGridDelegate(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: screenWidth > 1650
          ? 4
          : screenWidth > 1200
              ? 3
              : screenWidth > 600
                  ? 2
                  : 1,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: aspectRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final delegate = gridDelegate ?? _buildDefaultGridDelegate(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? screenWidth * 0.02 : horizontalPadding,
        vertical: verticalPadding,
      ),
      child: GridView.builder(
        itemCount: dataList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: delegate,
        itemBuilder: (context, index) {
          return buildCard(dataList[index]);
        },
      ),
    );
  }
}
