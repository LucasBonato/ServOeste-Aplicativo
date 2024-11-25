import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextFormField extends StatefulWidget {
  final bool hide;
  final String hint;
  final String label;
  final int maxLength;
  final TextInputType type;
  final String? initialValue;
  final double? rightPadding;
  final double? leftPadding;
  final int? maxLines;
  final TextEditingController? controller;
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final List<MaskTextInputFormatter>? masks;
  final String? Function([String?])? validator;
  final ValueNotifier<String> valueNotifier;

  const CustomTextFormField({
    super.key,
    required this.valueNotifier,
    required this.maxLength,
    required this.label,
    required this.hint,
    required this.hide,
    required this.type,
    this.initialValue,
    this.rightPadding,
    this.leftPadding,
    this.controller,
    this.validator,
    this.onChanged,
    this.maxLines,
    this.onSaved,
    this.masks,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    _internalController =
        TextEditingController(text: widget.valueNotifier.value);

    widget.valueNotifier.addListener(() {
      if (_internalController.text != widget.valueNotifier.value) {
        _internalController.text = widget.valueNotifier.value;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(widget.leftPadding ?? 16, 4,
          widget.rightPadding ?? 16, widget.hide ? 16 : 0),
      child: ValueListenableBuilder<String>(
        valueListenable: widget.valueNotifier,
        builder: (BuildContext context, String value, Widget? child) =>
            TextFormField(
          controller: _internalController,
          inputFormatters: widget.masks,
          maxLength: widget.maxLength,
          keyboardType: widget.type,
          maxLines: widget.maxLines ?? 1,
          minLines: 1,
          decoration: InputDecoration(
            counterText: widget.hide ? "" : null,
            hintText: widget.hint,
            labelText: widget.label,
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFFFF8F7),
            hintStyle: const TextStyle(
              color: Color(0xFFB0A9A9),
              fontSize: 16,
            ),
            labelStyle: const TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontSize: 16,
            ),
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
                color: Colors.black54,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
          onChanged: widget.onChanged,
          validator: widget.validator,
          onSaved: widget.onSaved,
        ),
      ),
    );
  }
}
