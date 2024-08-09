import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final Function(String) onChangedAction;
  final double? leftPadding;
  final double? rightPadding;

  const SearchTextField({
    super.key,
    required this.hint,
    required this.onChangedAction,
    required this.controller,
    this.keyboardType,
    this.leftPadding,
    this.rightPadding
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.leftPadding?? 16, 4, widget.rightPadding?? 16, 0),
      child: TextFormField(
        obscureText: false,
        controller: widget.controller,
        keyboardType: widget.keyboardType?? TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_outlined,
            color: Color(0xFF57636C),
          ),
          isDense: false,
          labelText: widget.hint,
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
        ),
        onChanged: (value) => setState(() {widget.onChangedAction(value);}),
      ),
    );
  }
}
