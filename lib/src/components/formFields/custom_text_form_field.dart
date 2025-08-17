import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextFormField extends StatefulWidget {
  final bool hide;
  final String label;
  final int maxLength;
  final TextInputType type;
  final String? hint;
  final bool? enabled;
  final String? initialValue;
  final double? rightPadding;
  final double? leftPadding;
  final int? maxLines;
  final int? minLines;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<MaskTextInputFormatter>? masks;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function([String?])? validator;
  final ValueNotifier<String> valueNotifier;
  final TextEditingController? controller;
  final IconButton? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.valueNotifier,
    required this.maxLength,
    required this.label,
    required this.hide,
    required this.type,
    this.hint,
    this.inputFormatters,
    this.initialValue,
    this.rightPadding,
    this.leftPadding,
    this.validator,
    this.onChanged,
    this.controller,
    this.maxLines,
    this.minLines,
    this.enabled,
    this.onSaved,
    this.onTap,
    this.masks,
    this.suffixIcon,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    _internalController = TextEditingController(text: widget.valueNotifier.value);

    widget.valueNotifier.addListener(() {
      if (_internalController.text != widget.valueNotifier.value) {
        _internalController.text = widget.valueNotifier.value;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.leftPadding ?? 16, 4, widget.rightPadding ?? 16, 0),
      child: ValueListenableBuilder<String>(
        valueListenable: widget.valueNotifier,
        builder: (BuildContext context, String value, Widget? child) => TextFormField(
          enabled: widget.enabled,
          controller: _internalController,
          inputFormatters: widget.masks ?? widget.inputFormatters,
          maxLength: widget.maxLength,
          keyboardType: widget.type,
          maxLines: widget.maxLines ?? 1,
          minLines: widget.minLines ?? 1,
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
              color: Color(0xFF948F8F),
              fontSize: 16,
            ),
            floatingLabelStyle: TextStyle(
              color: _internalController.text.isNotEmpty || FocusScope.of(context).hasFocus ? Colors.black : Color(0xFF948F8F),
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
                color: Colors.blueAccent,
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
            suffixIcon: widget.suffixIcon,
          ),
          onChanged: (value) {
            widget.onChanged?.call(value);
            widget.valueNotifier.value = value;
          },
          onTap: widget.onTap,
          validator: widget.validator,
          onSaved: widget.onSaved,
        ),
      ),
    );
  }
}
