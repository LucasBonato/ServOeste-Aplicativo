
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';

import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';

class TecnicoSearchField extends StatefulWidget {
  final TecnicoBloc tecnicoBloc;
  final TextEditingController? controller;
  final void Function(String) onChanged;
  final void Function(TecnicoResponse)? onSelected;
  final VoidCallback? onSearchStart;
  final List<ValueListenable>? listenTo;
  final String label;
  final bool enabled;
  final int maxLength;
  final String? Function([String?])? validator;
  final bool Function()? enabledCalculator;
  final String? tooltipMessage;
  final TecnicoSearchEvent Function(String nome) buildSearchEvent;

  const TecnicoSearchField({
    super.key,
    required this.tecnicoBloc,
    required this.controller,
    required this.onChanged,
    this.onSelected,
    required this.label,
    this.enabled = true,
    this.maxLength = 50,
    this.validator,
    this.tooltipMessage,
    required this.buildSearchEvent,
    this.onSearchStart,
    this.listenTo,
    this.enabledCalculator,
  });

  @override
  State<TecnicoSearchField> createState() => _TecnicoSearchFieldState();
}

class _TecnicoSearchFieldState extends State<TecnicoSearchField> {
  final Debouncer _debouncer = Debouncer();
  final ValueNotifier<List<String>> _names = ValueNotifier([]);
  List<TecnicoResponse> _tecnicos = [];

  void _handleChange(String name) {
    widget.onChanged.call(name);

    _debouncer.execute(() {
      if (name.split(" ").length > 1 && _names.value.isEmpty) return;

      widget.onSearchStart?.call();
      widget.tecnicoBloc.add(widget.buildSearchEvent(name));
    });
  }

  void _handleSelected(String name) {
    final TecnicoResponse? match = _tecnicos.firstWhereOrNull(
      (tecnico) => "${tecnico.nome} ${tecnico.sobrenome}" == name
    );
    if (match != null) {
      widget.onSelected?.call(match);
    }
  }

  Widget _buildField(bool enabled) {
    final Widget field = BlocListener<TecnicoBloc, TecnicoState>(
      bloc: widget.tecnicoBloc,
      listener: (context, state) {
        if (state is TecnicoSearchSuccessState) {
          _tecnicos = state.tecnicos;
          final names = state.tecnicos
              .take(5)
              .map((t) => "${t.nome} ${t.sobrenome}")
              .toList();
          _names.value = names;
        }
      },
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _names,
        builder: (context, names, _) {
          return CustomSearchDropDownFormField(
            leftPadding: 4,
            rightPadding: 4,
            label: widget.label,
            dropdownValues: names,
            maxLength: widget.maxLength,
            controller: widget.controller,
            hide: false,
            enabled: enabled,
            onChanged: _handleChange,
            onSelected: _handleSelected,
            validator: widget.validator,
          );
        },
      ),
    );

    return (widget.tooltipMessage?.isNotEmpty?? false)
        ? Tooltip(
          message: (enabled) ? "" : widget.tooltipMessage!,
          textAlign: TextAlign.center,
          child: field,
        )
        : field;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listenTo != null && widget.enabledCalculator != null) {
      return AnimatedBuilder(
        animation: Listenable.merge(widget.listenTo!),
        builder: (context, _) {
          return _buildField(widget.enabledCalculator!());
        },
      );
    }
    return _buildField(widget.enabled);
  }
}
