import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';

class BaseFormScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;

  const BaseFormScreen({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBarForm(
        title: title,
        onPressed: onBack,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
