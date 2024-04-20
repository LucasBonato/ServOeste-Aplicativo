import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final String hint;
  final Function(String) onChangedAction;

  const SearchTextField({super.key, required this.hint, required this.onChangedAction});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
      child: TextFormField(
        obscureText: false,
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
