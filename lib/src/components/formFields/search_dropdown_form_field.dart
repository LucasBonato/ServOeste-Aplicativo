import 'package:flutter/material.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

class CustomSearchDropDownFormField extends StatefulWidget {
  final List<String> dropdownValues;
  final void Function(String)? onChanged;
  final int? maxLength;
  final String label;
  final bool hide;
  final bool enabled;
  final bool searchDecoration;
  final double? leftPadding;
  final double? rightPadding;
  final TextEditingController? controller;
  final Function(String)? onSelected;
  final void Function(String?)? onSaved;
  final String? Function([String?])? validator;
  final Widget Function(BuildContext, String)? itemWidgetBuilder;
  final ValueNotifier<String?>? valueNotifier;

  const CustomSearchDropDownFormField({
    super.key,
    this.hide = false,
    this.enabled = true,
    this.searchDecoration = false,
    this.rightPadding,
    this.leftPadding,
    this.onSelected,
    this.onSaved,
    this.validator,
    this.controller,
    this.maxLength,
    this.itemWidgetBuilder,
    required this.onChanged,
    required this.label,
    required this.dropdownValues,
    this.valueNotifier,
  });

  @override
  State<CustomSearchDropDownFormField> createState() => _CustomSearchDropDown();
}

class _CustomSearchDropDown extends State<CustomSearchDropDownFormField> {
  late final TextEditingController _customSearchController;
  late Color labelColor;
  bool _isDisposed = false;

  @override
  void initState() {
    _customSearchController = widget.controller ?? TextEditingController();
    labelColor = const Color(0xFF948F8F);

    if (widget.valueNotifier?.value != null) {
      _customSearchController.text = widget.valueNotifier!.value!;
    }

    _customSearchController.addListener(_onTextChanged);
    super.initState();
  }

  void _onTextChanged() {
    if (_isDisposed || !mounted) return;

    setState(() {
      labelColor = _customSearchController.text.isNotEmpty
          ? const Color(0xFF948F8F)
          : const Color(0xFF000000);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _customSearchController.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _customSearchController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        widget.leftPadding ?? 16,
        4,
        widget.rightPadding ?? 16,
        widget.hide ? 16 : 0,
      ),
      child: DropDownSearchFormField(
        onSaved: widget.onSaved,
        validator: widget.validator,
        displayAllSuggestionWhenTap: false,
        textFieldConfiguration: TextFieldConfiguration(
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          controller: _customSearchController,
          onChanged: (value) {
            widget.onChanged!(value);
            widget.valueNotifier?.value = value;
          },
          decoration: InputDecoration(
            counterText: widget.hide ? null : "",
            labelText: widget.label,
            labelStyle: TextStyle(
              color: labelColor,
              fontSize: 16,
            ),
            suffixIcon: const Icon(
              Icons.arrow_drop_down_outlined,
              color: Color(0xFF948F8F),
            ),
            isDense: true,
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
                color: Colors.blueAccent,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
        suggestionsCallback: (query) async {
          if (query.isEmpty) return widget.dropdownValues;
          return widget.dropdownValues
              .where((element) =>
                  element.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        onSuggestionSelected: (String? suggestion) {
          if (suggestion != null && suggestion.isNotEmpty && !_isDisposed) {
            setState(() {
              _customSearchController.text = suggestion;
              widget.onChanged!(suggestion);
              widget.valueNotifier?.value = suggestion;
              widget.onSelected?.call(suggestion);
            });
            FocusScope.of(context).unfocus();
          }
        },
        itemBuilder: (context, suggestion) {
          return widget.itemWidgetBuilder != null
              ? widget.itemWidgetBuilder!(context, suggestion)
              : ListTile(
                  title: Text(suggestion),
                );
        },
        hideOnEmpty: true,
        debounceDuration: const Duration(milliseconds: 150),
        transitionBuilder: (context, suggestionBox, animationController) {
          final animation = CurvedAnimation(
            parent: animationController!,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: animation,
            child: suggestionBox,
          );
        },
        suggestionsBoxVerticalOffset: widget.hide ? -20 : 0,
      ),
    );
  }
}
