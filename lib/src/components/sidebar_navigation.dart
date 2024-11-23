import 'package:flutter/material.dart';
import 'package:serv_oeste/src/screens/home.dart';
import 'package:serv_oeste/src/screens/cliente/cliente.dart';
import 'package:serv_oeste/src/screens/servico/servico.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico.dart';

class SidebarNavigation extends StatefulWidget {
  final int currentIndex; // Novo parâmetro para o índice ativo

  const SidebarNavigation({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const Home(),
    const TecnicoPage(),
    const ClientePage(),
    const Servico(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex; // Sincroniza o índice inicial
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 768;

    if (!isLargeScreen) return const SizedBox.shrink();

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 25),
      decoration: const BoxDecoration(
        color: Color.fromARGB(253, 253, 253, 255),
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
                  icon: Icons.home,
                  label: 'Home',
                ),
                const Divider(color: Colors.black),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.build,
                  label: 'Técnicos',
                ),
                const Divider(color: Colors.black),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.people,
                  label: 'Clientes',
                ),
                const Divider(color: Colors.black),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.paste,
                  label: 'Serviços',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '© 2024 Serv-Oeste',
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
    final bool isSelected = _selectedIndex == index;

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
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => _screens[index],
            ),
          );
        }
      },
    );
  }
}
