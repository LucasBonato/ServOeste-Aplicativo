import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

abstract class SearchInputField {
  final String? Function([String?])? validator;
  final ValueNotifier<String>? valueNotifier;
  final void Function(String)? onChanged;
  final List<ValueListenable>? listenTo;
  final bool shouldExpand;
  final bool startNewRow;
  final bool enabled;
  final String hint;
  final int flex;

  const SearchInputField({
    required this.valueNotifier,
    required this.hint,
    this.shouldExpand = false,
    this.startNewRow = false,
    this.enabled = true,
    this.flex = 1,
    this.validator,
    this.onChanged,
    this.listenTo,
  });
}

class TextInputField extends SearchInputField {
  final TextEditingController controller;
  final TextInputType keyboardType;

  TextInputField({
    required super.hint,
    super.shouldExpand = false,
    super.startNewRow = false,
    super.enabled = true,
    super.flex = 1,
    super.valueNotifier,
    super.validator,
    super.onChanged,
    super.listenTo,
    required this.controller,
    required this.keyboardType,
  });
}

class TextFormInputField extends SearchInputField {
  final List<TextInputFormatter>? formatter;
  final List<MaskTextInputFormatter>? mask;
  final int maxLength;
  final String label;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool enableValueNotifierSync;

  TextFormInputField({
    required super.valueNotifier,
    required super.validator,
    required super.onChanged,
    required super.hint,
    required this.keyboardType,
    required this.label,
    super.listenTo,
    super.shouldExpand = false,
    super.startNewRow = false,
    super.enabled = true,
    super.flex = 1,
    this.maxLength = 255,
    this.formatter,
    this.mask,
    this.controller,
    this.enableValueNotifierSync = true,
  });
}

class DropdownInputField extends SearchInputField {
  final List<String> dropdownValues;

  DropdownInputField({
    required super.valueNotifier,
    required super.onChanged,
    required super.hint,
    super.shouldExpand = false,
    super.startNewRow = false,
    super.enabled = true,
    super.flex = 1,
    super.validator,
    super.listenTo,
    required this.dropdownValues,
  });
}

class DropdownSearchInputField extends SearchInputField {
  final List<String> dropdownValues;

  DropdownSearchInputField({
    required super.valueNotifier,
    required super.onChanged,
    required super.hint,
    super.shouldExpand = false,
    super.startNewRow = false,
    super.enabled = true,
    super.flex = 1,
    super.validator,
    super.listenTo,
    required this.dropdownValues,
  });
}

class DatePickerInputField extends SearchInputField {
  final List<MaskTextInputFormatter>? mask;

  DatePickerInputField({
    required super.valueNotifier,
    required super.onChanged,
    required super.hint,
    super.shouldExpand = false,
    super.startNewRow = false,
    super.enabled = true,
    super.flex = 1,
    super.validator,
    super.listenTo,
    this.mask,
  });
}
