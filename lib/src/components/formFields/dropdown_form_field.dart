import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatefulWidget {
  final String label;
  final bool? enabled;
  final double? leftPadding;
  final double? rightPadding;
  final List<String> dropdownValues;
  final ValueNotifier<String> valueNotifier;
  final String? Function([String?])? validator;
  final void Function(String) onChanged;

  const CustomDropdownFormField({
    super.key,
    required this.dropdownValues,
    required this.valueNotifier,
    required this.onChanged,
    required this.label,
    this.rightPadding = 4,
    this.leftPadding = 4,
    this.validator,
    this.enabled,
  });

  @override
  State<CustomDropdownFormField> createState() => _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  late SingleSelectController<String> _internalController;
  bool _isHovered = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _internalController = SingleSelectController<String>(null);
    widget.valueNotifier.addListener(_onNotifierValueChanged);
    _synchronizeControllerWithValueNotifier();
  }

  void _onNotifierValueChanged() {
    if (!mounted) return;
    _synchronizeControllerWithValueNotifier();
  }

  void _synchronizeControllerWithValueNotifier() {
    final String notifierValue = widget.valueNotifier.value;
    String? targetControllerValue = widget.dropdownValues.contains(notifierValue) ? notifierValue : null;

    if (_internalController.value != targetControllerValue) {
      _internalController.value = targetControllerValue;
    }
  }

  @override
  void didUpdateWidget(CustomDropdownFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valueNotifier != oldWidget.valueNotifier) {
      oldWidget.valueNotifier.removeListener(_onNotifierValueChanged);
      widget.valueNotifier.addListener(_onNotifierValueChanged);
      _synchronizeControllerWithValueNotifier();
    } else if (widget.dropdownValues != oldWidget.dropdownValues) {
      _synchronizeControllerWithValueNotifier();
    }
  }

  @override
  void dispose() {
    widget.valueNotifier.removeListener(_onNotifierValueChanged);
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.leftPadding ?? 16, 4, widget.rightPadding ?? 16, 0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          if (mounted) {
            setState(() {
              _isHovered = true;
            });
          }
        },
        onExit: (_) {
          if (mounted) {
            setState(() {
              _isHovered = false;
            });
          }
        },
        child: Focus(
          onFocusChange: (hasFocus) {
            if (mounted) {
              setState(() {
                _hasFocus = hasFocus;
              });
            }
          },
          child: ValueListenableBuilder<String>(
            valueListenable: widget.valueNotifier,
            builder: (BuildContext context, String value, Widget? child) {
              return CustomDropdown<String>(
                controller: _internalController,
                enabled: widget.enabled ?? true,
                items: widget.dropdownValues,
                hintText: widget.label,
                hintBuilder: (context, hint, enabled) => Text(
                  hint,
                  style: const TextStyle(
                    color: Color(0xFF948F8F),
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                closedHeaderPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                excludeSelected: false,
                validator: widget.validator,
                onChanged: (String? value) {
                  if (value != null && widget.valueNotifier.value != value) {
                    widget.valueNotifier.value = value;
                  }

                  if (value != null) widget.onChanged(value);
                },
                disabledDecoration: CustomDropdownDisabledDecoration(
                  fillColor: const Color(0xFFFFF8F7),
                  border: Border.all(color: Colors.black38),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black38, size: 20),
                ),
                decoration: CustomDropdownDecoration(
                  errorStyle: TextStyle(fontSize: 12, decoration: TextDecoration.none),
                  closedSuffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black38, size: 20),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
