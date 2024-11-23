import 'package:flutter/material.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

class CustomSearchDropDown extends StatefulWidget {
  final List<String> dropdownValues;
  final Function(String) onChanged;
  final int? maxLength;
  final double? suggestionVerticalOffset;
  final String label;
  final bool hide;
  final bool searchDecoration;
  final double? leftPadding;
  final double? rightPadding;
  final TextEditingController? controller;
  final Function(String)? onSelected;
  final void Function(String?)? onSaved;
  final String? Function([String?])? validator;
  final Widget Function(BuildContext, String)? itemWidgetBuilder;

  const CustomSearchDropDown({
    super.key,
    this.hide = false,
    this.searchDecoration = false,
    this.rightPadding,
    this.leftPadding,
    this.onSelected,
    this.onSaved,
    this.validator,
    this.controller,
    this.maxLength,
    this.suggestionVerticalOffset,
    this.itemWidgetBuilder,
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
    _customSearchController = widget.controller ?? TextEditingController();
    super.initState();
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
          maxLength: widget.maxLength,
          controller: _customSearchController,
          onChanged: widget.onChanged,
          decoration: widget.searchDecoration
              ? InputDecoration(
                  counterText: widget.hide ? "" : null,
                  labelText: widget.label,
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Color(0xFF57636C),
                  ),
                  isDense: false,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFF1F4F8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF4B39EF),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F4F8),
                )
              : InputDecoration(
                  counterText: widget.hide ? "" : null,
                  labelText: widget.label,
                  isDense: true,
                  fillColor: const Color(0xFFF1F4F8),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
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
          if (nome.isEmpty) return widget.dropdownValues;
          return widget.dropdownValues
              .where((element) =>
                  element.toLowerCase().contains(nome.toLowerCase()))
              .toList();
        },
        onSuggestionSelected: (String? suggestion) {
          if (suggestion != null && suggestion.isNotEmpty) {
            setState(() {
              _customSearchController.text = suggestion;
              widget.onChanged(suggestion);
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
        suggestionsBoxVerticalOffset: widget.suggestionVerticalOffset ?? -20,
      ),
    );
  }
}
