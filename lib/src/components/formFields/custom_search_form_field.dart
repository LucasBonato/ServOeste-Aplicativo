import 'package:flutter/material.dart';

class CustomSearchTextFormField extends StatefulWidget {
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Function(String)? onChangedAction;
  final Function(String)? onSuffixAction;
  final double? leftPadding;
  final double? rightPadding;

  const CustomSearchTextFormField({
    super.key,
    required this.hint,
    this.onChangedAction,
    this.onSuffixAction,
    this.controller,
    this.keyboardType,
    this.leftPadding,
    this.rightPadding,
  });

  @override
  State<CustomSearchTextFormField> createState() =>
      _CustomSearchTextFormFieldState();
}

class _CustomSearchTextFormFieldState extends State<CustomSearchTextFormField> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
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
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _internalController,
        builder: (context, value, child) {
          return TextFormField(
            obscureText: false,
            controller: _internalController,
            keyboardType: widget.keyboardType ?? TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search_outlined,
                color: Color(0xFF948F8F),
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF948F8F),
                      ),
                      onPressed: () {
                        setState(() {
                          _internalController.clear();
                          widget.controller?.clear();
                        });
                        widget.onSuffixAction?.call("");
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
                  color: Colors.blueAccent,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
            onChanged: widget.onChangedAction,
          );
        },
      ),
    );
  }
}
