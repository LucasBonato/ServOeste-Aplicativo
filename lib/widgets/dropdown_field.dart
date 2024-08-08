import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final List<String> dropdownValues;
  final TextEditingController controller;
  final double? rightPadding;
  final double? leftPadding;

  const CustomDropdownField({
    super.key,
    this.rightPadding,
    this.leftPadding,
    required this.label,
    required this.dropdownValues,
    required this.controller
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.leftPadding != null ? widget.leftPadding! : 16, 4, widget.rightPadding != null ? widget.rightPadding! : 16, 16),
      child: CustomDropdown<String>(
        hintText: widget.label,
        hintBuilder: (context, hint, enabled) => Text(hint, style: const TextStyle(color: Colors.black87, fontSize: 16)),
        items: widget.dropdownValues,
        onChanged: (String? value) {
          setState(() {
            widget.controller.text = value!;
          });
        },
        decoration: CustomDropdownDecoration(
          closedBorder: Border.all(
            color: Colors.blueAccent,
            width: 2
          ),
          closedBorderRadius: const BorderRadius.all(Radius.circular(5)),
          closedFillColor: Colors.transparent,
          expandedBorderRadius: const BorderRadius.all(Radius.circular(4)),
          expandedBorder: Border.all(
            color: Colors.blueAccent,
            width: 2
          ),
          headerStyle: const TextStyle(color: Colors.black87, fontSize: 16),
          closedErrorBorder: Border.all(
            color: Colors.red,
            width: 2
          ),
        ),
        excludeSelected: false,
        closedHeaderPadding: const EdgeInsets.all(8),
      )
    );
  }
}