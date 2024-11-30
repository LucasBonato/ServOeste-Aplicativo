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
  bool _isHovered = false;
  bool _hasFocus = false;

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
      child: MouseRegion(
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
              return CustomDropdown<String>(
                items: widget.dropdownValues,
                controller: _internalController,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class ScrollableDropdown extends StatelessWidget {
  final List<String> items;
  final void Function(String?) onChanged;

  const ScrollableDropdown({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Column(
          children: items
              .map((item) => ListTile(
                    title: Text(item),
                    onTap: () {
                      onChanged(item);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
