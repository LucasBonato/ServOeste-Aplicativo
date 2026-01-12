import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';

class ClienteSearchField extends StatefulWidget {
  final ClienteBloc clienteBloc;
  final TextEditingController? controller;
  final void Function(String) onChanged;
  final void Function(Cliente)? onSelected;
  final VoidCallback? onSearchStart;
  final List<ValueListenable>? listenTo;
  final String label;
  final bool enabled;
  final int maxLength;
  final String? Function([String?])? validator;
  final bool Function()? enabledCalculator;
  final String? tooltipMessage;
  final bool isForListScreen;

  const ClienteSearchField({
    super.key,
    required this.clienteBloc,
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
  State<ClienteSearchField> createState() => _ClienteSearchFieldState();
}

class _ClienteSearchFieldState extends State<ClienteSearchField> {
  final Debouncer _debouncer = Debouncer();
  final ValueNotifier<List<String>> _names = ValueNotifier([]);
  List<Cliente> _clientes = [];

  void _handleChange(String name) {
    widget.onChanged.call(name);

    _debouncer.execute(() {
      if (name.split(" ").length > 1 && _names.value.isEmpty) return;

      widget.onSearchStart?.call();

      if (widget.isForListScreen) {
        widget.clienteBloc.add(ClienteSearchMenuEvent(nome: name));
      } else {
        widget.clienteBloc.add(ClienteSearchEvent(nome: name));
      }
    });
  }

  void _handleSelected(String name) {
    final Cliente? match =
        _clientes.firstWhereOrNull((cliente) => cliente.nome == name);
    if (match != null) {
      widget.onSelected?.call(match);
    }
  }

  Widget _buildField(bool enabled) {
    final Widget field = BlocListener<ClienteBloc, ClienteState>(
      bloc: widget.clienteBloc,
      listener: (context, state) {
        if (state is ClienteSearchSuccessState) {
          _clientes = state.clientes;
          final names =
              state.clientes.take(5).map((cliente) => cliente.nome!).toList();
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
          return _buildField(widget.enabledCalculator!());
        },
      );
    }
    return _buildField(widget.enabled);
  }
}
