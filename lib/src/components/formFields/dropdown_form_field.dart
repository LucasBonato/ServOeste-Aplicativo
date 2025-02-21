import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class CustomDropdownFormField extends StatefulWidget {
  final String label;
  final bool? enabled;
  final double? leftPadding;
  final double? rightPadding;
  final List<String> dropdownValues;
  final ValueNotifier<String> valueNotifier;
  final String? Function([String?])? validator;
  final void Function(String) onChanged;
  final SingleSelectController<String>? controller;

  const CustomDropdownFormField({
    super.key,
    required this.dropdownValues,
    required this.valueNotifier,
    required this.onChanged,
    required this.label,
    this.rightPadding,
    this.leftPadding,
    this.controller,
    this.validator,
    this.enabled,
  });

  @override
  State<CustomDropdownFormField> createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  late SingleSelectController<String> _internalController;
  late SingleSelectController<String> _effectiveController;
  bool _isHovered = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    final initialValue =
        widget.dropdownValues.contains(widget.valueNotifier.value)
            ? widget.valueNotifier.value
            : widget.dropdownValues.isNotEmpty
                ? widget.dropdownValues.first
                : null;

    _internalController = SingleSelectController(initialValue);
    _effectiveController = widget.controller ?? _internalController;

    widget.valueNotifier.addListener(_updateController);
  }

  void _updateController() {
    if (widget.dropdownValues.contains(widget.valueNotifier.value)) {
      _effectiveController.value = widget.valueNotifier.value;
    }
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
          child: ValueListenableBuilder<String>(
            valueListenable: widget.valueNotifier,
            builder: (BuildContext context, String value, Widget? child) {
              if (!widget.dropdownValues.contains(value)) {
                value = widget.dropdownValues.isNotEmpty
                    ? widget.dropdownValues.first
                    : "";
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && widget.dropdownValues.contains(value)) {
                  _effectiveController.value = value;
                }
              });

              return CustomDropdown<String>(
                enabled: widget.enabled ?? true,
                disabledDecoration: CustomDropdownDisabledDecoration(
                  fillColor: const Color(0xFFFFF8F7),
                  border: Border.all(color: Colors.black38),
                  suffixIcon: Icon(Icons.arrow_drop_down,
                      color: Colors.black38, size: 20),
                ),
                items: widget.dropdownValues,
                controller: _effectiveController,
                hintText: widget.label,
                hintBuilder: (context, hint, enabled) => Text(
                  hint,
                  style: const TextStyle(
                    color: Color(0xFF948F8F),
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                decoration: CustomDropdownDecoration(
                  errorStyle:
                      TextStyle(fontSize: 12, decoration: TextDecoration.none),
                  closedSuffixIcon: Icon(Icons.arrow_drop_down,
                      color: Colors.black38, size: 20),
                  closedFillColor: _isHovered
                      ? const Color(0xFFF5EEED)
                      : (widget.enabled ?? true)
                          ? const Color(0xFFFFF8F7)
                          : const Color(0xFFE2E1E0),
                  closedBorderRadius: BorderRadius.circular(12),
                  expandedBorderRadius: BorderRadius.circular(12),
                  closedBorder: Border.all(
                    color: _hasFocus
                        ? Colors.black
                        : (widget.enabled ?? true)
                            ? const Color(0xFFEAE6E5)
                            : const Color(0xFFCCCBCB),
                    width: 1,
                  ),
                  expandedBorder: Border.all(
                    color: Colors.blueAccent,
                    width: 1,
                  ),
                  expandedFillColor: const Color(0xFFFFF8F7),
                ),
                closedHeaderPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                excludeSelected: false,
                validator: widget.validator,
                onChanged: (String? value) {
                  if (value != null) widget.onChanged(value);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
