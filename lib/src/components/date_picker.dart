import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';

//ignore: must_be_immutable
class CustomDatePicker extends StatefulWidget {
  final String? restorationId;
  final String hint;
  final String label;
  final List<MaskTextInputFormatter>? mask;
  final int maxLength;
  final TextInputType type;
  final double? rightPadding;
  final double? leftPadding;
  late bool? validation;
  final Function(String?)? onChanged;
  final String? Function([String?])? validator;
  final ValueNotifier<String> valueNotifier;
  final bool hide;

  CustomDatePicker({
    super.key,
    this.hide = false,
    this.validation,
    this.onChanged,
    this.validator,
    this.leftPadding,
    this.rightPadding,
    this.restorationId,
    required this.hint,
    required this.label,
    required this.mask,
    required this.maxLength,
    required this.type,
    required this.valueNotifier,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  String _dateSelected = "";

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) =>
        navigator.restorablePush(_datePickerRoute, arguments: _selectedDate.value.millisecondsSinceEpoch),
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
          selectableDayPredicate: (DateTime day) {
            return day.weekday != DateTime.sunday;
          },
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
        widget.valueNotifier.value = _dateSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.leftPadding ?? 16, 4,
        widget.rightPadding ?? 16, 0,
      ),
      child: CustomTextFormField(
        valueNotifier: widget.valueNotifier,
        hide: widget.hide,
        label: widget.label,
        hint: widget.hint,
        validator: widget.validator,
        masks: widget.mask,
        maxLength: widget.maxLength,
        type: widget.type,
        onChanged: widget.onChanged,
        onTap: () {
          _restorableDatePickerRouteFuture.present();
          setState(() {
            widget.validation = false;
          });
        },
      )
    );
  }
}