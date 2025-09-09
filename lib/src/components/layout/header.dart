import 'package:flutter/material.dart';

class HeaderComponent extends StatelessWidget {
  final VoidCallback onLogout;

  const HeaderComponent({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 10,
      ),
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFCFDFDFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 45,
                  maxHeight: 50,
                  maxWidth: isLargeScreen ? 275 : 200,
                ),
                child: Image.asset(
                  'assets/servOeste.png',
                  width: isLargeScreen ? 275 : 200,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: onLogout,
              icon: Icon(
                Icons.logout,
                color: Colors.blueAccent,
                size: isLargeScreen ? 28 : 24,
              ),
              tooltip: 'Sair',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                padding: EdgeInsets.all(isLargeScreen ? 8 : 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
