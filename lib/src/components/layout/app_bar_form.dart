import 'package:flutter/material.dart';

class AppBarForm extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final void Function()? onPressed;
  final List<Widget>? actions;

  const AppBarForm({
    super.key,
    required this.title,
    this.onPressed,
    this.actions
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onPressed?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      backgroundColor: const Color(0xFCFDFDFF),
      elevation: 0,
      actions: actions,
    );
  }
}