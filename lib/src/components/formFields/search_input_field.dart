import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

abstract class SearchInputField {
  final bool shouldExpand;
  final bool startNewRow;
  final String hint;
  final int flex;

  const SearchInputField({
    required this.hint,
    this.shouldExpand = false,
    this.startNewRow = false,
    this.flex = 1,
  });
}

class TextInputField extends SearchInputField {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final VoidCallback? onChanged;

  TextInputField({
    super.shouldExpand = false,
    super.flex = 1,
    required super.hint,
    required this.controller,
    required this.keyboardType,
    this.onChanged,
  });
}

class TextFormInputField extends SearchInputField {
  final TextInputType keyboardType;
  final String label;
  final int maxLength;
  final List<MaskTextInputFormatter>? mask;
  final ValueNotifier<String> valueNotifier;
  final String? Function([String?])? validator;
  final void Function(String?)? onChanged;

  TextFormInputField({
    super.shouldExpand = false,
    super.flex = 1,
    required super.hint,
    required this.label,
    required this.maxLength,
    required this.keyboardType,
    required this.valueNotifier,
    required this.validator,
    required this.onChanged,
    this.mask,
  });
}

class DropdownInputField extends SearchInputField {
  final SingleSelectController<String> controller;
  final ValueNotifier<String> valueNotifier;
  final List<String> dropdownValues;
  final void Function(String)? onChanged;

  DropdownInputField({
    super.shouldExpand = false,
    super.flex = 1,
    required super.hint,
    required this.controller,
    required this.valueNotifier,
    required this.dropdownValues,
    required this.onChanged,
  });
}
