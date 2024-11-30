import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

class CustomDatePicker extends StatefulWidget {
  final String? restorationId;
  final String hint;
  final String label;
  final String? mask;
  final int? maxLength;
  final TextEditingController controller;
  final String errorMessage;
  final TextInputType type;
  final double? rightPadding;
  final double? leftPadding;
  final Function(String?)? onChanged;
  final bool hide;
  final ValueNotifier<String>? valueNotifier;
  final String? Function(String?)? validator;

  CustomDatePicker({
    super.key,
    this.restorationId,
    required this.hint,
    required this.label,
    this.mask,
    required this.errorMessage,
    required this.controller,
    required this.type,
    this.hide = false,
    this.maxLength,
    this.onChanged,
    this.leftPadding,
    this.rightPadding,
    this.valueNotifier,
    this.validator,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker>
    with RestorationMixin {
  String? get restorationId => widget.restorationId;

  String _dateSelected = "";
  bool _validation = false;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        _dateSelected =
            '${_selectedDate.value.day < 10 ? '0${_selectedDate.value.day}' : _selectedDate.value.day}/${_selectedDate.value.month < 10 ? '0${_selectedDate.value.month}' : _selectedDate.value.month}/${_selectedDate.value.year}';
        widget.controller.text = _dateSelected;

        if (widget.valueNotifier != null) {
          widget.valueNotifier!.value =
              _dateSelected; // Atualiza o ValueNotifier
        }
      });
    }
  }

  void _toggleValidation(bool value) {
    setState(() {
      _validation = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.leftPadding ?? 16,
        4,
        widget.rightPadding ?? 16,
        0,
      ),
      child: TextFormField(
        controller: widget.controller,
        maxLength: widget.maxLength,
        keyboardType: widget.type,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFFB0A9A9),
          ),
          isDense: true,
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: Color(0xFFB0A9A9),
            fontSize: 16,
          ),
          labelText: widget.label,
          labelStyle: const TextStyle(
            color: Color(0xFFB0A9A9),
          ),
          filled: true,
          fillColor: const Color(0xFFFFF8F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFEAE6E5),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFEAE6E5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF6C757D),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          errorText: _validation ? widget.errorMessage : null,
        ),
        onTap: () {
          _restorableDatePickerRouteFuture.present();
          _toggleValidation(false);
        },
        onChanged: (value) {
          widget.onChanged?.call(value);

          if (widget.validator != null) {
            setState(() {
              _validation = widget.validator!(value) != null;
            });
          }
        },
        validator: widget.validator,
      ),
    );
  }
}
