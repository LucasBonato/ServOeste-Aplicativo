import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

//ignore: must_be_immutable
class CustomDatePicker extends StatefulWidget {
  final String? restorationId;
  final String hint;
  final String label;
  final String? mask;
  final int maxLength;
  final TextEditingController controller;
  final String errorMessage;
  final TextInputType type;
  final double? rightPadding;
  final double? leftPadding;
  late bool validation;
  final Function(String?)? onChanged;
  final bool hide;

  CustomDatePicker({
    super.key,
    this.restorationId,
    required this.hint,
    required this.label,
    required this.mask,
    required this.errorMessage,
    required this.maxLength,
    required this.controller,
    required this.type,
    required this.validation,
    this.hide = false,
    this.onChanged,
    this.leftPadding,
    this.rightPadding
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> with RestorationMixin{
  @override
  String? get restorationId => widget.restorationId;
  String _dateSelected = "";

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(_datePickerRoute, arguments: _selectedDate.value.millisecondsSinceEpoch);
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
    registerForRestoration(_restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        _dateSelected = '${_selectedDate.value.day < 10 ? '0${_selectedDate.value.day}' : _selectedDate.value.day}/${_selectedDate.value.month < 10 ? '0${_selectedDate.value.month}' : _selectedDate.value.month}/${_selectedDate.value.year}';
        widget.controller.text = _dateSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(widget.leftPadding != null ? widget.leftPadding! : 16, 4, widget.rightPadding != null ? widget.rightPadding! : 16, widget.hide ? 16 : 0),
      child: MaskedTextField(
        controller: widget.controller,
        mask: widget.mask,
        maxLength: widget.maxLength,
        keyboardType: widget.type,
        decoration: InputDecoration(
          counterText: widget.hide ? "" : null,
          error: (widget.validation) ? Text(widget.errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red),) : null,
          hintText: widget.hint,
          labelText: widget.label,
          isDense: true,
          fillColor: const Color(0xFFF1F4F8),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 2
            )
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        onChanged: widget.onChanged,
        onTap: () {
          _restorableDatePickerRouteFuture.present();
          setState(() {
            widget.validation = false;
          });
        },
      ),
    );
  }
}
