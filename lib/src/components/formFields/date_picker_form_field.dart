import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';

class CustomDatePickerFormField extends StatefulWidget {
  final String? restorationId;
  final String hint;
  final String label;
  final List<MaskTextInputFormatter>? mask;
  final int maxLength;
  final TextInputType type;
  final bool? enabled;
  final double? rightPadding;
  final double? leftPadding;
  final bool? validation;
  final Function(String?)? onChanged;
  final String? Function([String?])? validator;
  final ValueNotifier<String> valueNotifier;
  final bool hide;

  const CustomDatePickerFormField({
    super.key,
    this.hide = false,
    this.enabled,
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
  State<CustomDatePickerFormField> createState() =>
      _CustomDatePickerFormFieldState();
}

class _CustomDatePickerFormFieldState extends State<CustomDatePickerFormField>
    with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  String _dateSelected = "";

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) =>
        navigator.restorablePush(_datePickerRoute,
            arguments: _selectedDate.value.millisecondsSinceEpoch),
  );

  final TextEditingController _controller = TextEditingController();

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        bool isSunday = (DateTime.now().weekday == DateTime.sunday);
        DateTime today = DateTime.now();
        DateTime tomorrow = today.add(const Duration(days: 1));
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: (isSunday) ? tomorrow : today,
          firstDate: (isSunday) ? tomorrow : today,
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
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        _dateSelected = DateFormat('dd/MM/yyyy').format(_selectedDate.value);

        widget.valueNotifier.value = _dateSelected;

        widget.onChanged?.call(_dateSelected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      enabled: widget.enabled,
      rightPadding: widget.rightPadding,
      leftPadding: widget.leftPadding,
      valueNotifier: widget.valueNotifier,
      hide: widget.hide,
      label: widget.label,
      hint: widget.hint,
      validator: widget.validator,
      masks: widget.mask,
      maxLength: widget.maxLength,
      type: widget.type,
      onChanged: widget.onChanged,
      controller: _controller,
      onTap: () {
        _restorableDatePickerRouteFuture.present();
      },
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () {
          _restorableDatePickerRouteFuture.present();
        },
      ),
    );
  }
}
