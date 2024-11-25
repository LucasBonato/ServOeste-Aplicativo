import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final double? leftPadding;
  final double? rightPadding;
  final List<String> dropdownValues;
  final ValueNotifier<String> valueNotifier;
  final String? Function([String?])? validator;
  final void Function(String?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.dropdownValues,
    required this.valueNotifier,
    required this.label,
    required this.onChanged,
    this.rightPadding,
    this.leftPadding,
    this.validator,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  late SingleSelectController<String> _internalController;

  @override
  void initState() {
    _internalController = SingleSelectController(
      (widget.dropdownValues.contains(widget.valueNotifier.value))
          ? widget.valueNotifier.value
          : widget.dropdownValues.first,
    );

    widget.valueNotifier.addListener(() {
      if (_internalController.value != widget.valueNotifier.value) {
        _internalController.value = widget.valueNotifier.value;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          widget.leftPadding ?? 16, 4, widget.rightPadding ?? 16, 16),
      child: ValueListenableBuilder<String>(
        valueListenable: widget.valueNotifier,
        builder: (BuildContext context, String value, Widget? child) =>
            CustomDropdown<String>(
          items: widget.dropdownValues,
          controller: _internalController,
          hintText: widget.label,
          hintBuilder: (context, hint, enabled) => Text(
            hint,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(
              color: Colors.transparent,
            ),
            expandedBorder: Border.all(
              color: Colors.blueAccent,
              width: 1.5,
            ),
            closedFillColor: const Color(0xFFFAF8F6),
            closedBorderRadius: BorderRadius.circular(10),
            closedShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 2),
              )
            ],
            expandedBorderRadius: BorderRadius.circular(10),
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
    );
  }
}
