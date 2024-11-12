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
    this.validator
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
        : widget.dropdownValues.first
    );

    widget.valueNotifier.addListener(() {
      if(_internalController.value != widget.valueNotifier.value) {
        _internalController.value = widget.valueNotifier.value;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.leftPadding?? 16, 4, widget.rightPadding?? 16, 16),
      child: ValueListenableBuilder<String>(
        valueListenable: widget.valueNotifier,
        builder: (BuildContext context, String value, Widget? child) => CustomDropdown<String>(
          items: widget.dropdownValues,
          controller: _internalController,
          hintText: widget.label,
          hintBuilder: (context, hint, enabled) => Text(hint, style: const TextStyle(color: Colors.black87, fontSize: 16)),
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(
              color: Colors.blueAccent,
              width: 2
            ),
            expandedBorder: Border.all(
              color: Colors.blueAccent,
              width: 2
            ),
            closedErrorBorder: Border.all(
              color: Colors.red,
              width: 2
            ),
            closedFillColor: Colors.transparent,
            headerStyle: const TextStyle(color: Colors.black87, fontSize: 16),
            closedBorderRadius: const BorderRadius.all(Radius.circular(5)),
            expandedBorderRadius: const BorderRadius.all(Radius.circular(4)),
            closedErrorBorderRadius: BorderRadius.all(Radius.circular(5))
          ),
          closedHeaderPadding: const EdgeInsets.all(8),
          excludeSelected: false,
          validator: widget.validator,
          onChanged: widget.onChanged,
        ),
      )
    );
  }
}