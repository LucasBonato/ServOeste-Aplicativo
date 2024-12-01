import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/bottom_navBar.dart';
import 'package:serv_oeste/src/components/sidebar_navigation.dart';
import 'package:serv_oeste/src/components/header.dart';

class BaseLayout extends StatefulWidget {
  final int initialIndex;
  final List<Widget> screens;

  const BaseLayout({
    super.key,
    required this.initialIndex,
    required this.screens,
  });

  @override
  _BaseLayoutState createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 800;

    return Scaffold(
      body: Row(
        children: [
          if (isLargeScreen)
            SidebarNavigation(
              currentIndex: _currentIndex,
              onSelect: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          Expanded(
            child: Column(
              children: [
                const HeaderComponent(),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: widget.screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
    );
  }
}
