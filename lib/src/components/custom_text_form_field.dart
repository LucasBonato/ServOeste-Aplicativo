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
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final void Function()? onTap;
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
    this.validator,
    this.onChanged,
    this.maxLines,
    this.onSaved,
    this.onTap,
    this.masks,
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
      if(_internalController.text != widget.valueNotifier.value) {
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
      padding: EdgeInsetsDirectional.fromSTEB(widget.leftPadding?? 16, 4, widget.rightPadding?? 16, widget.hide ? 16 : 0),
      child: ValueListenableBuilder<String>(
        valueListenable: widget.valueNotifier,
        builder: (BuildContext context, String value, Widget? child) => TextFormField(
          controller: _internalController,
          inputFormatters: widget.masks,
          maxLength: widget.maxLength,
          keyboardType: widget.type,
          maxLines: widget.maxLines?? 1,
          minLines: 1,
          decoration: InputDecoration(
            counterText: widget.hide ? "" : null,
            hintText: widget.hint,
            labelText: widget.label,
            isDense: true,
            fillColor: const Color(0xFFF1F4F8),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blueAccent,
                width: 2
              )
            ),
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
          onTap: widget.onTap,
          validator: widget.validator,
          onSaved: widget.onSaved,
        ),
      ),
    );
  }
}
