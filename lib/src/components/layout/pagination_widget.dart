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

    final theme = Theme.of(context);
    final selectedBgColor = selectedColor ?? theme.colorScheme.primary;
    final unselectedBgColor = unselectedColor ?? theme.colorScheme.surface;
    final selectedTextColor = theme.colorScheme.onPrimary;
    final unselectedTextColor = theme.colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentPage > 1)
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onPageChanged(currentPage - 1),
          )
        else
          const IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: null,
          ),
        if (currentPage > (maxVisiblePages ~/ 2) + 1 && totalPages > maxVisiblePages)
          _buildPageButton(
            1,
            currentPage,
            selectedBgColor,
            unselectedBgColor,
            selectedTextColor,
            unselectedTextColor,
            onPageChanged,
          ),
        if (currentPage > (maxVisiblePages ~/ 2) + 2 && totalPages > maxVisiblePages)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...'),
          ),
        ..._generatePageNumbers().map(
          (page) => _buildPageButton(
            page,
            currentPage,
            selectedBgColor,
            unselectedBgColor,
            selectedTextColor,
            unselectedTextColor,
            onPageChanged,
          ),
        ),
        if (currentPage < totalPages - (maxVisiblePages ~/ 2) - 1 && totalPages > maxVisiblePages)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...'),
          ),
        if (currentPage < totalPages - (maxVisiblePages ~/ 2) && totalPages > maxVisiblePages)
          _buildPageButton(
            totalPages,
            currentPage,
            selectedBgColor,
            unselectedBgColor,
            selectedTextColor,
            unselectedTextColor,
            onPageChanged,
          ),
        if (currentPage < totalPages)
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onPageChanged(currentPage + 1),
          )
        else
          const IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: null,
          ),
      ],
    );
  }

  List<int> _generatePageNumbers() {
    final List<int> pages = [];
    int startPage = currentPage - (maxVisiblePages ~/ 2);
    int endPage = currentPage + (maxVisiblePages ~/ 2);

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

  Widget _buildPageButton(
    int page,
    int currentPage,
    Color selectedBgColor,
    Color unselectedBgColor,
    Color selectedTextColor,
    Color unselectedTextColor,
    Function(int) onPageChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        shape: const CircleBorder(),
        color: page == currentPage ? selectedBgColor : unselectedBgColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onPageChanged(page),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              '$page',
              style: (textStyle ?? const TextStyle()).copyWith(
                color: page == currentPage ? selectedTextColor : unselectedTextColor,
                fontWeight: page == currentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
