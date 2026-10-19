import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

abstract class InputField {
  final ValueNotifier<String>? valueNotifier;
  final List<ValueListenable>? listenTo;
  final String? Function([String?])? validator;
  final bool shouldExpand;
  final bool startNewRow;
  final bool enabled;
  final int flex;

  const InputField({
    required this.valueNotifier,
    this.shouldExpand = false,
    this.startNewRow = false,
    this.enabled = true,
    this.flex = 1,
    this.validator,
    this.listenTo,
  });
}

class CustomWidgetField {
  final Widget child;
  final bool shouldExpand;
  final bool startNewRow;
  final int flex;

  const CustomWidgetField({
    required this.child,
    this.shouldExpand = false,
    this.startNewRow = false,
    this.flex = 1,
  });
}

abstract class SearchInputField extends InputField {
  final void Function(String)? onChanged;
  final String hint;

  const SearchInputField({
    required super.valueNotifier,
    super.shouldExpand,
    super.startNewRow,
    super.validator,
    super.listenTo,
    super.enabled,
    super.flex,
    required this.hint,
    this.onChanged,
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

class TextSearchFormInputField extends SearchInputField {
  final String label;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onSuffix;

  TextSearchFormInputField({
    required super.validator,
    required super.onChanged,
    required super.hint,
    required this.keyboardType,
    required this.label,
    super.valueNotifier,
    super.listenTo,
    super.shouldExpand = false,
    super.startNewRow = false,
    super.enabled = true,
    super.flex = 1,
    this.controller,
    this.onSuffix,
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
  final bool allowPastDates;
  final bool allowFutureDates;

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
    this.allowPastDates = false,
    this.allowFutureDates = true,
    this.mask,
  });
}

class ButtonInputField extends InputField {
  final String text;
  final VoidCallback onPressed;
  final String? tooltipMessage;
  final bool Function()? enabledCalculator;

  ButtonInputField({
    required super.valueNotifier,
    super.shouldExpand,
    super.startNewRow,
    super.validator,
    super.listenTo,
    super.enabled,
    super.flex,
    required this.onPressed,
    required this.text,
    this.tooltipMessage,
    this.enabledCalculator
  });
}
