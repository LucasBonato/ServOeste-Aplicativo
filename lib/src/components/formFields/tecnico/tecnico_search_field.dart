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
  final bool isForListScreen;

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
    this.onSearchStart,
    this.listenTo,
    this.enabledCalculator,
    this.isForListScreen = false,
  });

  @override
  State<TecnicoSearchField> createState() => _TecnicoSearchFieldState();
}

class _TecnicoSearchFieldState extends State<TecnicoSearchField> {
  final Debouncer _debouncer = Debouncer();
  final ValueNotifier<List<String>> _names = ValueNotifier([]);
  List<TecnicoResponse> _tecnicos = [];
  bool _hasInitialFetch = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialTecnicos();
    });
  }

  void _fetchInitialTecnicos() {
    if (!_hasInitialFetch) {
      _hasInitialFetch = true;

      if (widget.isForListScreen) {
        widget.tecnicoBloc.add(TecnicoSearchMenuEvent(nome: ''));
      }
    }
  }

  void _handleChange(String name) {
    widget.onChanged.call(name);

    _debouncer.execute(() {
      widget.onSearchStart?.call();

      if (name.isEmpty) {
        widget.tecnicoBloc.add(TecnicoSearchMenuEvent(nome: ''));
      } else {
        widget.tecnicoBloc.add(TecnicoSearchMenuEvent(nome: name));
      }
    });
  }

  void _handleSelected(String name) {
    final TecnicoResponse? match = _tecnicos.firstWhereOrNull(
        (tecnico) => "${tecnico.nome} ${tecnico.sobrenome}" == name);
    if (match != null) {
      widget.onSelected?.call(match);
    }
  }

  void _filterAndUpdateNames(String searchText) {
    if (_tecnicos.isEmpty) return;

    List<TecnicoResponse> filteredTecnicos;

    if (searchText.isEmpty) {
      filteredTecnicos = _tecnicos.take(5).toList();
    } else {
      final searchLower = searchText.toLowerCase();
      filteredTecnicos = _tecnicos
          .where((tecnico) {
            final fullName =
                "${tecnico.nome} ${tecnico.sobrenome}".toLowerCase();
            return fullName.contains(searchLower) ||
                tecnico.nome!.toLowerCase().contains(searchLower) ||
                tecnico.sobrenome!.toLowerCase().contains(searchLower);
          })
          .take(5)
          .toList();
    }

    final names =
        filteredTecnicos.map((t) => "${t.nome} ${t.sobrenome}").toList();
    if (!listEquals(names, _names.value)) {
      _names.value = names;
    }
  }

  Widget _buildField(bool enabled) {
    return BlocListener<TecnicoBloc, TecnicoState>(
      bloc: widget.tecnicoBloc,
      listener: (context, state) {
        if (state is TecnicoSearchSuccessState) {
          _tecnicos = state.tecnicos;
          final currentText = widget.controller?.text ?? '';
          _filterAndUpdateNames(currentText);
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
  }

  Widget _buildFieldWithTooltip(bool enabled) {
    final field = _buildField(enabled);

    return (widget.tooltipMessage?.isNotEmpty ?? false)
        ? Tooltip(
            message: (enabled) ? "" : widget.tooltipMessage!,
            textAlign: TextAlign.center,
            child: field,
          )
        : field;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listenTo != null && widget.enabledCalculator != null) {
      return AnimatedBuilder(
        animation: Listenable.merge(widget.listenTo!),
        builder: (context, _) {
          return _buildFieldWithTooltip(widget.enabledCalculator!());
        },
      );
    }
    return _buildFieldWithTooltip(widget.enabled);
  }
}
