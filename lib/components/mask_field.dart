import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

//ignore: must_be_immutable
class CustomMaskField extends StatefulWidget {
  final String hint;
  final String label;
  final String? mask;
  final int maxLength;
  final TextEditingController controller;
  final String errorMessage;
  final TextInputType type;
  bool validation;
  Function(String?)? onChanged;
  bool hide;


  CustomMaskField({
    super.key,
    required this.hint,
    required this.label,
    required this.mask,
    required this.errorMessage,
    required this.maxLength,
    required this.controller,
    required this.type,
    required this.validation,
    this.hide = false,
    this.onChanged
  });

  @override
  State<CustomMaskField> createState() => _CustomMaskFieldState();
}

class _CustomMaskFieldState extends State<CustomMaskField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 4, 16, widget.hide ? 16 : 0),
      child: MaskedTextField(
        controller: widget.controller,
        mask: widget.mask,
        maxLength: widget.maxLength,
        keyboardType: widget.type,
        decoration: InputDecoration(
          counterText: widget.hide ? "" : null,
          errorText: (widget.validation) ? widget.errorMessage : null,
          hintText: widget.hint,
          labelText: widget.label,
          isDense: true,
          fillColor: const Color(0xFFF1F4F8),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
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
        onTap: () => {
          setState(() {
            widget.validation = false;
          })
        },
      ),
    );
  }
}
