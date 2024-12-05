import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final double? leftPadding;
  final double? rightPadding;
  final List<String> dropdownValues;
  final ValueNotifier<String?> valueNotifier;
  final String? Function([String?])? validator;
  final void Function(String?) onChanged;
  final SingleSelectController<String>? controller;

  const CustomDropdownField({
    super.key,
    required this.dropdownValues,
    required this.valueNotifier,
    required this.label,
    required this.onChanged,
    this.rightPadding,
    this.leftPadding,
    this.validator,
    this.controller,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  late SingleSelectController<String> _internalController;
  late SingleSelectController<String> _effectiveController;
  bool _isHovered = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _internalController = SingleSelectController(
      widget.valueNotifier.value != null &&
              widget.dropdownValues.contains(widget.valueNotifier.value)
          ? widget.valueNotifier.value
          : null,
    );

    _effectiveController = widget.controller ?? _internalController;

    widget.valueNotifier.addListener(() {
      if (_effectiveController.value != widget.valueNotifier.value) {
        _effectiveController.value = widget.valueNotifier.value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          widget.leftPadding ?? 16, 4, widget.rightPadding ?? 16, 16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() {
          _isHovered = true;
        }),
        onExit: (_) => setState(() {
          _isHovered = false;
        }),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;
            });
          },
          child: ValueListenableBuilder<String?>(
            valueListenable: widget.valueNotifier,
            builder: (BuildContext context, String? value, Widget? child) =>
                CustomDropdown<String>(
              items: widget.dropdownValues,
              controller: _effectiveController,
              hintText: widget.label,
              hintBuilder: (context, hint, enabled) => Text(
                hint,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
              decoration: CustomDropdownDecoration(
                closedFillColor: _isHovered
                    ? const Color(0xFFF5EEED)
                    : const Color(0xFFFFF8F7),
                closedBorderRadius: BorderRadius.circular(12),
                expandedBorderRadius: BorderRadius.circular(12),
                closedBorder: Border.all(
                  color: _hasFocus ? Colors.black : const Color(0xFFEAE6E5),
                  width: _hasFocus ? 1.5 : 1,
                ),
                expandedBorder: Border.all(
                  color: Colors.blueAccent,
                  width: 1.5,
                ),
              ),
              closedHeaderPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              excludeSelected: false,
              validator: widget.validator,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }
}
