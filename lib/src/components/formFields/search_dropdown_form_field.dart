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
  late final TextEditingController _effectiveController;
  late Color labelColor;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    labelColor = const Color(0xFF948F8F);

    _synchronizeControllerWithValueNotifier();

    _effectiveController.addListener(_onInternalControllerTextChanged);

    widget.valueNotifier?.addListener(_onExternalNotifierChanged);
  }

  void _onExternalNotifierChanged() {
    if (_isDisposed || !mounted) return;
    _synchronizeControllerWithValueNotifier();
  }

  void _synchronizeControllerWithValueNotifier() {
    if (widget.valueNotifier != null) {
      final String notifierText = widget.valueNotifier!.value ?? "";
      if (_effectiveController.text != notifierText) {
        _effectiveController.text = notifierText;
      }
    }
  }

  void _onInternalControllerTextChanged() {
    if (_isDisposed || !mounted) return;
    if (mounted) {
      setState(() {
        labelColor = _effectiveController.text.isNotEmpty
            ? const Color(0xFF948F8F)
            : const Color(0xFF000000);
      });
    }
  }

  @override
  void didUpdateWidget(CustomSearchDropDownFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _effectiveController.removeListener(_onInternalControllerTextChanged);

      if (widget.controller != null) {
        final newText = widget.controller!.text;
        if (_effectiveController.text != newText) {
          _effectiveController.text = newText;
        }
      }

      _effectiveController.addListener(_onInternalControllerTextChanged);
      _synchronizeControllerWithValueNotifier();
    }

    if (widget.valueNotifier != oldWidget.valueNotifier) {
      oldWidget.valueNotifier?.removeListener(_onExternalNotifierChanged);
      widget.valueNotifier?.addListener(_onExternalNotifierChanged);
      _synchronizeControllerWithValueNotifier();
    } else {
      _synchronizeControllerWithValueNotifier();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _effectiveController.removeListener(_onInternalControllerTextChanged);
    widget.valueNotifier?.removeListener(_onExternalNotifierChanged);
    if (widget.controller == null) {
      _effectiveController.dispose();
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
          controller: _effectiveController,
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
              _effectiveController.text = suggestion;
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
