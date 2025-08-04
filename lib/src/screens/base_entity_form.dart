import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/screen/elevated_form_button.dart';

typedef BuildFormFields = List<Object> Function();

class BaseEntityForm<B extends StateStreamable<S>, S> extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final BuildFormFields buildFields;
  final Future<void> Function() onSubmit;
  final B bloc;
  final String submitText;
  final double space;
  final bool Function(S state) isLoading;
  final bool Function(S state) isSuccess;
  final bool Function(S state) isError;
  final String Function(S state)? getErrorMessage;
  final VoidCallback? onSuccess;

  const BaseEntityForm({
    super.key,
    required this.formKey,
    required this.buildFields,
    required this.onSubmit,
    required this.bloc,
    required this.submitText,
    required this.isLoading,
    required this.isSuccess,
    required this.isError,
    this.getErrorMessage,
    this.onSuccess,
    this.space = 8
  });

  @override
  State<BaseEntityForm<B, S>> createState() => _BaseEntityFormState<B, S>();
}

class _BaseEntityFormState<B extends StateStreamable<S>, S> extends State<BaseEntityForm<B, S>> {
  late final List<Object> _cachedFields = widget.buildFields();
  List<Object> get _fields => _cachedFields;

  Widget _buildFormContent(BuildContext context, bool isLargeScreen) {
    final fields = isLargeScreen
        ? _buildLargeScreenFormFields()
        : _buildSmallScreenFormFields();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...fields,
        const SizedBox(height: 24),
        BlocBuilder<B, S>(
          builder: (context, state) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: ElevatedFormButton(
                text: widget.submitText,
                onPressed: widget.isLoading(context.read<B>().state) ? null : widget.onSubmit,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormField(SearchInputField field) {
    if (field is TextFormInputField) {
      return CustomTextFormField(
        hide: true,
        leftPadding: 4,
        rightPadding: 4,
        maxLength: field.maxLength,
        type: field.keyboardType,
        hint: field.hint,
        label: field.label,
        masks: field.mask,
        valueNotifier: field.valueNotifier,
        validator: field.validator,
        onChanged: field.onChanged,
      );
    }
    else if (field is DropdownInputField) {
      return CustomDropdownFormField(
        leftPadding: 4,
        rightPadding: 4,
        label: field.hint,
        dropdownValues: field.dropdownValues,
        controller: field.controller,
        valueNotifier: field.valueNotifier,
        onChanged: (value) {
          field.valueNotifier.value = value;
          field.onChanged?.call(value);
        },
      );
    }
    return const SizedBox.shrink();
  }

  List<List<Widget>> _chunkFieldsIntoRows(List<Object> fields) {
    List<List<Widget>> rows = [];
    List<Widget> currentRow = [];

    void flushRow() {
      rows.add(currentRow);
      currentRow = [];
      currentRow.add(SizedBox(height: widget.space));
      rows.add(currentRow);
      currentRow = [];
    }

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];

      if (field is! SearchInputField) {
        if (currentRow.isNotEmpty) {
          flushRow();
        }
        if (field is Wrap && field.children.length > 1) {
          currentRow = field.children
              .map((input) => Expanded(child: input))
              .toList();
          flushRow();
          continue;
        }

        currentRow.add(field is Widget ? field : const SizedBox.shrink());
        flushRow();
        continue;
      }

      Widget formField = _buildFormField(field);

      if (field.shouldExpand) {
        formField = Expanded(flex: field.flex, child: formField);
        currentRow.add(formField);
      }
      else {
        if (currentRow.isNotEmpty) {
          flushRow();
        }

        currentRow.add(formField);
        flushRow();
      }

      final bool isLastField = (i == fields.length - 1);

      if (isLastField && currentRow.isNotEmpty) {
        flushRow();
      }
    }

    return rows;
  }

  List<Widget> _buildLargeScreenFormFields() {
    final List<List<Widget>> rows = _chunkFieldsIntoRows(_fields);

    return [
      for (final List<Widget> row in rows)
        if (row.length > 1)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: row,
          )
        else
          ...row
    ];
  }

  List<Widget> _buildSmallScreenFormFields() {
    return _fields
      .map((field) {
        if (field is Widget) {
          return field;
        }
        if (field is SearchInputField) {
          return _buildFormField(field);
        }
        return const SizedBox.shrink();
      })
      .expand((element) => [element, SizedBox(height: widget.space)])
      .toList()
      ..removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      bloc: widget.bloc,
      listener: (context, state) {
        if (widget.isSuccess(state)) {
          widget.onSuccess?.call();
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro adicionado com sucesso!')),
          );
        }
        else if (widget.isError(state)) {
          final errorMessage = widget.getErrorMessage?.call(state) ?? "Erro ao salvar registro";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: widget.isLoading(state),
          child: Form(
            key: widget.formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLargeScreen = constraints.maxWidth >= 750;
                return _buildFormContent(context, isLargeScreen);
              },
            ),
          ),
        );
      },
    );
  }
}
