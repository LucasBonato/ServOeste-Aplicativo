import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

class CustomMaskFormField extends StatefulWidget {
  final String hint;
  final String label;
  final String? mask;
  final int maxLength;
  final TextEditingController? controller;
  final String? errorMessage;
  final TextInputType type;
  final double? rightPadding;
  final double? leftPadding;
  final int? maxLines;
  final bool? validation;
  final Function(String?)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool hide;

  const CustomMaskFormField({
    super.key,
    required this.hint,
    required this.label,
    required this.maxLength,
    required this.type,
    this.errorMessage,
    this.mask,
    this.controller,
    this.validation,
    this.hide = false,
    this.onChanged,
    this.leftPadding,
    this.rightPadding,
    this.maxLines,
    this.validator,
    this.onSaved,
  });

  @override
  State<CustomMaskFormField> createState() => _CustomMaskFormFieldState();
}

class _CustomMaskFormFieldState extends State<CustomMaskFormField> {
  late bool _hide;

  @override
  void initState() {
    super.initState();
    _hide = widget.hide;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        widget.leftPadding ?? 16,
        4,
        widget.rightPadding ?? 16,
        _hide ? 16 : 0,
      ),
      child: MaskedTextField(
        controller: widget.controller,
        mask: widget.mask,
        maxLength: widget.maxLength,
        keyboardType: widget.type,
        maxLines: widget.maxLines ?? 1,
        minLines: 1,
        decoration: InputDecoration(
          counterText: _hide ? "" : null,
          hintText: widget.hint,
          labelText: widget.label,
          isDense: true,
          fillColor: const Color(0xFFF1F4F8),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF007BFF),
              width: 2,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        onChanged: widget.onChanged,
        validator: widget.validator,
        onSaved: widget.onSaved,
        onTap: () => setState(() {}),
      ),
    );
  }
}
