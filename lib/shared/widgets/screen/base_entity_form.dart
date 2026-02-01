import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/shared/widgets/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/date_picker_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_input_field.dart';
import 'package:serv_oeste/shared/widgets/screen/elevated_form_button.dart';

typedef BuildFormFields = List<Object> Function();

class BaseEntityForm<B extends StateStreamable<S>, S> extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final BuildFormFields buildFields;
  final Future<void> Function() onSubmit;
  final String Function(S state)? getSuccessMessage;
  final B bloc;
  final String submitText;
  final double space;
  final bool Function(S state) isLoading;
  final bool Function(S state) isSuccess;
  final bool Function(S state) isError;
  final bool shouldBuildButton;
  final String Function(S state)? getErrorMessage;
  final void Function(S state)? onError;
  final VoidCallback? onSuccess;

  const BaseEntityForm({
    super.key,
    required this.formKey,
    required this.buildFields,
    required this.onSubmit,
    required this.getSuccessMessage,
    required this.bloc,
    required this.submitText,
    required this.isLoading,
    required this.isSuccess,
    required this.isError,
    this.getErrorMessage,
    this.onError,
    this.onSuccess,
    this.space = 8,
    this.shouldBuildButton = true,
  });

  @override
  State<BaseEntityForm<B, S>> createState() => _BaseEntityFormState<B, S>();
}

class _BaseEntityFormState<B extends StateStreamable<S>, S> extends State<BaseEntityForm<B, S>> {
  Widget _buildFormContent(BuildContext context, bool isLargeScreen, List<Object> currentFields) {
    final fields = isLargeScreen ? _buildLargeScreenFormFields(currentFields) : _buildSmallScreenFormFields(currentFields);

    final button = widget.shouldBuildButton
        ? [
            SizedBox(height: 24),
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
          ]
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [...fields, ...button],
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
        enableValueNotifierSync: field.enableValueNotifierSync,
        inputFormatters: field.formatter,
        minLines: field.keyboardType == TextInputType.multiline ? 1 : null,
        maxLines: field.keyboardType == TextInputType.multiline ? 3 : null,
        valueNotifier: field.valueNotifier!,
        validator: field.validator,
        onChanged: field.onChanged,
        enabled: field.enabled,
      );
    }
    else if (field is TextSearchFormInputField) {
      return CustomSearchTextFormField(
        hint: field.hint,
        leftPadding: 4,
        rightPadding: 4,
        controller: field.controller,
        keyboardType: field.keyboardType,
        onChangedAction: field.onChanged,
        onSuffixAction: field.onSuffix,
      );
    }
    else if (field is DropdownInputField) {
      return CustomDropdownFormField(
        leftPadding: 4,
        rightPadding: 4,
        label: field.hint,
        dropdownValues: field.dropdownValues,
        valueNotifier: field.valueNotifier!,
        validator: field.validator,
        enabled: field.enabled,
        onChanged: (value) {
          field.valueNotifier!.value = value;
          field.onChanged?.call(value);
        },
      );
    }
    else if (field is DropdownSearchInputField) {
      return CustomSearchDropDownFormField(
        leftPadding: 4,
        rightPadding: 4,
        label: field.hint,
        dropdownValues: field.dropdownValues,
        valueNotifier: field.valueNotifier,
        validator: field.validator,
        onChanged: field.onChanged,
        enabled: field.enabled,

      );
    }
    else if (field is DatePickerInputField) {
      return CustomDatePickerFormField(
        label: field.hint,
        hint: "dd/mm/aaaa",
        leftPadding: 4,
        rightPadding: 4,
        mask: field.mask,
        type: TextInputType.datetime,
        maxLength: 10,
        hide: true,
        valueNotifier: field.valueNotifier!,
        validator: field.validator,
        onChanged: field.onChanged,
        enabled: field.enabled,
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
          currentRow = field.children.map((input) => Expanded(child: input)).toList();
          flushRow();
          continue;
        }

        currentRow.add(field is Widget ? field : const SizedBox.shrink());
        flushRow();
        continue;
      }

      Widget formField = _buildFormField(field);

      if (field.listenTo != null && field.listenTo!.isNotEmpty) {
        formField = AnimatedBuilder(animation: Listenable.merge(field.listenTo!), builder: (context, child) => child!, child: formField);
      }

      if (field.startNewRow && currentRow.isNotEmpty) {
        flushRow();
      }

      if (field.shouldExpand) {
        formField = Expanded(flex: field.flex, child: formField);
        currentRow.add(formField);
      } else {
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

  List<Widget> _buildLargeScreenFormFields(List<Object> fields) {
    final List<List<Widget>> rows = _chunkFieldsIntoRows(fields);

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

  List<Widget> _buildSmallScreenFormFields(List<Object> fields) {
    return fields
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
      listenWhen: (previous, current) {
        return !widget.isSuccess(previous) && widget.isSuccess(current) ||
            !widget.isError(previous) && widget.isError(current);
      },
      listener: (context, state) {
        if (widget.isSuccess(state)) {
          widget.onSuccess?.call();
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }

          final successMessage = widget.getSuccessMessage?.call(state) ?? 'Operação realizada com sucesso!';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
        else if (widget.isError(state)) {
          widget.onError?.call(state);

          final errorMessage = widget.getErrorMessage?.call(state) ?? "Erro ao realizar operação";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final List<Object> currentFields = widget.buildFields();
        return AbsorbPointer(
          absorbing: widget.isLoading(state),
          child: Form(
            key: widget.formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLargeScreen = constraints.maxWidth >= 450;
                return _buildFormContent(context, isLargeScreen, currentFields);
              },
            ),
          ),
        );
      },
    );
  }
}
