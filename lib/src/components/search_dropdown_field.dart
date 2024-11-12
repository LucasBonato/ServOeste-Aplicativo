import 'package:flutter/material.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

class CustomSearchDropDown extends StatefulWidget {
  final List<String> dropdownValues;
  final Function(String) onChanged;
  final int maxLength;
  final String label;
  final bool hide;
  final double? leftPadding;
  final double? rightPadding;
  final Function(String)? onSelected;
  final void Function(String?)? onSaved;
  final String? Function([String?])? validator;

  const CustomSearchDropDown({
    super.key,
    this.rightPadding,
    this.leftPadding,
    this.hide = false,
    this.onSelected,
    this.onSaved,
    this.validator,
    required this.maxLength,
    required this.onChanged,
    required this.label,
    required this.dropdownValues,
  });

  @override
  State<CustomSearchDropDown> createState() => _CustomSearchDropDown();
}

class _CustomSearchDropDown extends State<CustomSearchDropDown> {
  late final TextEditingController _customSearchController;

  @override
  void initState() {
    _customSearchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(widget.leftPadding?? 16, 4, widget.rightPadding?? 16, widget.hide ? 16 : 0),
      child: DropDownSearchFormField(
        onSaved: widget.onSaved,
        validator: widget.validator,
        displayAllSuggestionWhenTap: false,
        textFieldConfiguration: TextFieldConfiguration(
          maxLength: widget.maxLength,
          controller: _customSearchController,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            counterText: widget.hide ? "" : null,
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
        ),
        suggestionsCallback: (nome) async {
          return widget.dropdownValues;
        },
        onSuggestionSelected: (String? suggestion) {
          _customSearchController.text = suggestion!;
          if(widget.onSelected != null) {
            widget.onSelected!(suggestion);
          }
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion)
          );
        },
        hideOnEmpty: true,
        debounceDuration: const Duration(milliseconds: 150),
        transitionBuilder: (context, suggestionBox, animationController) { return suggestionBox; },
        suggestionsBoxVerticalOffset: -20,
      ),
    );
  }
}