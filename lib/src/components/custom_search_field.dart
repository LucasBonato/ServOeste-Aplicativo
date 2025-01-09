import 'package:flutter/material.dart';

class CustomSearchTextField extends StatefulWidget {
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Function(String)? onChangedAction;
  final double? leftPadding;
  final double? rightPadding;

  const CustomSearchTextField({
    super.key,
    required this.hint,
    this.onChangedAction,
    this.controller,
    this.keyboardType,
    this.leftPadding,
    this.rightPadding,
  });

  @override
  State<CustomSearchTextField> createState() => _CustomSearchTextFieldState();
}

class _CustomSearchTextFieldState extends State<CustomSearchTextField> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    _internalController = widget.controller ?? TextEditingController();
    _internalController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.leftPadding ?? 16,
        4,
        widget.rightPadding ?? 16,
        0,
      ),
      child: TextFormField(
        obscureText: false,
        controller: _internalController,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_outlined,
            color: Color(0xFF948F8F),
          ),
          suffixIcon: _internalController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF948F8F),
                  ),
                  onPressed: () {
                    _internalController.clear();
                    if (widget.onChangedAction != null) {
                      widget.onChangedAction!("");
                    }
                  },
                )
              : null,
          isDense: true,
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: Color(0xFF948F8F),
            fontSize: 16,
          ),
          filled: true,
          fillColor: const Color(0xFFFFF8F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFEAE6E5),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFEAE6E5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF6C757D),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
        onChanged: widget.onChangedAction,
      ),
    );
  }
}
