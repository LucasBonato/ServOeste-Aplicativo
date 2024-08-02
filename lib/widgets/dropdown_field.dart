import 'package:flutter/material.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final List<String> dropdownValues;
  final TextEditingController controller;
  final double? rightPadding;
  final double? leftPadding;

  const CustomDropdownField({
    super.key,
    this.rightPadding,
    this.leftPadding,
    required this.label,
    required this.dropdownValues,
    required this.controller
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _overlayEntry?.remove();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _toggleDropdown();
    } else {
      _overlayEntry?.remove();
      _isDropdownOpen = false;
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.isNotEmpty && _focusNode.hasFocus) {
      _toggleDropdown();
    } else {
      _overlayEntry?.remove();
      _isDropdownOpen = false;
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _overlayEntry?.remove();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width - 64,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(16, 55),
            child: Material(
              elevation: 4.0,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.dropdownValues.map((value) => ListTile(
                  title: Text(value, textAlign: TextAlign.center),
                  dense: true,
                  onTap: () {
                    widget.controller.text = value;
                    _toggleDropdown();
                  },
                )).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(widget.leftPadding != null ? widget.leftPadding! : 16, 4, widget.rightPadding != null ? widget.rightPadding! : 16, 16),
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: widget.label,
                isDense: true,
                fillColor: const Color(0xFFF1F4F8),
                suffixIcon: IconButton(
                  icon: Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  onPressed: _toggleDropdown,
                ),
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
              )
            ),
          ),
        ],
      ),
    );
  }
}