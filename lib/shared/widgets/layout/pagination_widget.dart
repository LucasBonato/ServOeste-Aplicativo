import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int maxVisiblePages;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? textStyle;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisiblePages = 5,
    this.selectedColor,
    this.unselectedColor,
    this.textStyle,
  }) : assert(maxVisiblePages >= 3, 'maxVisiblePages deve ser pelo menos 3');

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;

        final double buttonSize = _getResponsiveValue(
          screenWidth,
          min: 28,
          max: 34,
          factor: 0.015,
        );

        final double fontSize = _getResponsiveValue(
          screenWidth,
          min: 10,
          max: 14,
          factor: 0.02,
        );

        final double iconSize = _getResponsiveValue(
          screenWidth,
          min: 14,
          max: 22,
          factor: 0.015,
        );

        final theme = Theme.of(context);
        final selectedBgColor = selectedColor ?? theme.colorScheme.primary;
        final unselectedBgColor = unselectedColor ?? theme.colorScheme.surface;
        final selectedTextColor = theme.colorScheme.onPrimary;
        final unselectedTextColor = theme.colorScheme.onSurface;

        final visibleMaxPages =
            isSmallScreen ? maxVisiblePages.clamp(3, 5) : maxVisiblePages;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPaginationItems(
            context: context,
            currentPage: currentPage,
            totalPages: totalPages,
            maxVisiblePages: visibleMaxPages,
            buttonSize: buttonSize,
            fontSize: fontSize,
            iconSize: iconSize,
            selectedBgColor: selectedBgColor,
            unselectedBgColor: unselectedBgColor,
            selectedTextColor: selectedTextColor,
            unselectedTextColor: unselectedTextColor,
            onPageChanged: onPageChanged,
            theme: theme,
            isSmallScreen: isSmallScreen,
          ),
        );
      },
    );
  }

  List<Widget> _buildPaginationItems({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
    required int maxVisiblePages,
    required double buttonSize,
    required double fontSize,
    required double iconSize,
    required Color selectedBgColor,
    required Color unselectedBgColor,
    required Color selectedTextColor,
    required Color unselectedTextColor,
    required Function(int) onPageChanged,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    final List<Widget> items = [];
    final int sidePages = (maxVisiblePages - 1) ~/ 2;

    items.add(
      _buildIconButton(
        context: context,
        icon: Icons.chevron_left,
        onPressed:
            currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        size: buttonSize,
        iconSize: iconSize,
        isEnabled: currentPage > 1,
      ),
    );

    if (currentPage > sidePages + 1) {
      items.add(_buildPageButton(
        page: 1,
        currentPage: currentPage,
        selectedBgColor: selectedBgColor,
        unselectedBgColor: unselectedBgColor,
        selectedTextColor: selectedTextColor,
        unselectedTextColor: unselectedTextColor,
        onPageChanged: onPageChanged,
        buttonSize: buttonSize,
        fontSize: fontSize,
      ));

      if (currentPage > sidePages + 1) {
        items.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
          child: Text(
            '...',
            style: TextStyle(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ));
      }
    }

    final pageNumbers = _generatePageNumbers(
      currentPage: currentPage,
      totalPages: totalPages,
      maxVisiblePages: maxVisiblePages,
    );

    for (final page in pageNumbers) {
      items.add(_buildPageButton(
        page: page,
        currentPage: currentPage,
        selectedBgColor: selectedBgColor,
        unselectedBgColor: unselectedBgColor,
        selectedTextColor: selectedTextColor,
        unselectedTextColor: unselectedTextColor,
        onPageChanged: onPageChanged,
        buttonSize: buttonSize,
        fontSize: fontSize,
      ));
    }

    if (currentPage < totalPages - sidePages - 1) {
      if (currentPage < totalPages - sidePages - 2) {
        items.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
          child: Text(
            '...',
            style: TextStyle(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ));
      }

      items.add(_buildPageButton(
        page: totalPages,
        currentPage: currentPage,
        selectedBgColor: selectedBgColor,
        unselectedBgColor: unselectedBgColor,
        selectedTextColor: selectedTextColor,
        unselectedTextColor: unselectedTextColor,
        onPageChanged: onPageChanged,
        buttonSize: buttonSize,
        fontSize: fontSize,
      ));
    }

    items.add(
      _buildIconButton(
        context: context,
        icon: Icons.chevron_right,
        onPressed: currentPage < totalPages
            ? () => onPageChanged(currentPage + 1)
            : null,
        size: buttonSize,
        iconSize: iconSize,
        isEnabled: currentPage < totalPages,
      ),
    );

    return items;
  }

  List<int> _generatePageNumbers({
    required int currentPage,
    required int totalPages,
    required int maxVisiblePages,
  }) {
    final List<int> pages = [];

    final int sidePages = (maxVisiblePages - 1) ~/ 4;

    int startPage = currentPage - sidePages;
    int endPage = currentPage + sidePages;

    if (startPage < 1) {
      endPage += 1 - startPage;
      startPage = 1;
    }

    if (endPage > totalPages) {
      startPage -= endPage - totalPages;
      endPage = totalPages;
    }

    startPage = startPage < 1 ? 1 : startPage;

    for (int i = startPage; i <= endPage; i++) {
      pages.add(i);
    }

    return pages;
  }

  Widget _buildPageButton({
    required int page,
    required int currentPage,
    required Color selectedBgColor,
    required Color unselectedBgColor,
    required Color selectedTextColor,
    required Color unselectedTextColor,
    required Function(int) onPageChanged,
    required double buttonSize,
    required double fontSize,
  }) {
    final bool isSelected = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        shape: const CircleBorder(),
        color: isSelected ? selectedBgColor : unselectedBgColor,
        elevation: isSelected ? 1 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: () => onPageChanged(page),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            child: Text(
              '$page',
              style: (textStyle ?? TextStyle()).copyWith(
                fontSize: fontSize,
                color: isSelected ? selectedTextColor : unselectedTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required Function()? onPressed,
    required double size,
    required double iconSize,
    required bool isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        shape: const CircleBorder(),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: iconSize,
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  double _getResponsiveValue(
    double screenWidth, {
    required double min,
    required double max,
    required double factor,
  }) {
    final value = min + (screenWidth * factor);
    return value.clamp(min, max);
  }
}
