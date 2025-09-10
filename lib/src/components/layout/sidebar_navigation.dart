import 'package:flutter/material.dart';

class SidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelect;

  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 768;

    if (!isLargeScreen) return const SizedBox.shrink();

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 25),
      decoration: const BoxDecoration(
        color: Color(0xFCFDFDFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2, 0),
            blurRadius: 5,
          ),
        ],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 75),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  label: 'Home',
                ),
                const Divider(color: Colors.black),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.build_outlined,
                  label: 'Técnicos',
                ),
                const Divider(color: Colors.black),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.people_outlined,
                  label: 'Clientes',
                ),
                const Divider(color: Colors.black),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.paste_outlined,
                  label: 'Serviços',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '© 2025 Serv-Oeste',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.black,
        size: isSelected ? 30 : 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (currentIndex != index) {
          onSelect(index);
        }
      },
    );
  }
}
