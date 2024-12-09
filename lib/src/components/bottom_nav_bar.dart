import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFCFDFDFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 8, spreadRadius: 0.5),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.home,
            label: "Home",
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.build,
            label: "Técnicos",
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.people,
            label: "Clientes",
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            context,
            index: 3,
            icon: Icons.content_paste,
            label: "Serviços",
            isSelected: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context,
      {required int index,
      required IconData icon,
      required String label,
      required bool isSelected}) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              key: ValueKey<int>(index),
              color: isSelected ? Colors.blue : Colors.black,
              size: 30,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
