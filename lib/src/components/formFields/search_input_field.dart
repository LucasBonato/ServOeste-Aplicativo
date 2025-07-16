import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

abstract class SearchInputField {
  const SearchInputField();
}

class TextInputField extends SearchInputField {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  TextInputField({
    required this.hint,
    required this.controller,
    required this.keyboardType
  });
}

class DropdownInputField extends SearchInputField {
  final String label;
  final SingleSelectController<String> controller;
  final ValueNotifier<String> valueNotifier;
  final List<String> dropdownValues;
  final void Function(String)? onChanged;

  DropdownInputField({
    required this.label,
    required this.controller,
    required this.valueNotifier,
    required this.dropdownValues,
    required this.onChanged
  });
}