import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';

class ResponsiveSearchInputs extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final double maxContainerWidth;
  final VoidCallback onChanged;
  final List<SearchInputField> fields;
  final double padding;

  const ResponsiveSearchInputs({
    super.key,
    required this.fields,
    required this.onChanged,
    this.onFilterTap,
    this.padding = 5,
    this.maxContainerWidth = 1200.0,
  });

  Widget _buildSearchField(SearchInputField field) {
    if (field is TextInputField) {
      return CustomSearchTextFormField(
        leftPadding: 4,
        rightPadding: 4,
        hint: field.hint,
        keyboardType: field.keyboardType,
        controller: field.controller,
        onChangedAction: (value) => onChanged(),
        onSuffixAction: (value) {
          field.controller.clear();
          onChanged.call();
        },
      );
    } else if (field is DropdownInputField) {
      return CustomDropdownFormField(
        leftPadding: 4,
        rightPadding: 4,
        label: field.hint,
        dropdownValues: field.dropdownValues,
        valueNotifier: field.valueNotifier!,
        onChanged: (value) {
          field.valueNotifier!.value = value;
          field.onChanged?.call(value);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFilterIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 4, top: 4),
      child: InkWell(
        onTap: onFilterTap,
        hoverColor: const Color(0xFFF5EEED),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFFFF8F7),
            border: Border.all(
              color: const Color(0xFFEAE6E5),
            ),
          ),
          child: const Icon(
            Icons.filter_list,
            size: 30.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  List<List<Widget>> _chunkFieldsIntoRows() {
    List<List<Widget>> listaDeListas = [];
    List<Widget> lista = [];

    for (int i = 1; i < fields.length; i++) {
      if (((i - 1) % 2 == 0) && (i != 1)) {
        listaDeListas.add(lista);
        lista = [];
      }

      lista.add(Expanded(flex: 1, child: _buildSearchField(fields[i])));
    }

    if (lista.isNotEmpty) {
      if (onFilterTap != null) {
        lista.add(_buildFilterIcon());
      }
      listaDeListas.add(lista);
    } else if (onFilterTap != null && listaDeListas.isNotEmpty) {
      listaDeListas.last.add(_buildFilterIcon());
    }

    return listaDeListas;
  }

  Widget _buildLargeScreenSearchBar() {
    return Row(
      children: [for (SearchInputField field in fields) Expanded(flex: 1, child: _buildSearchField(field)), if (onFilterTap != null) _buildFilterIcon()],
    );
  }

  Widget _buildMediumScreenSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(fields.first),
        if (fields.length > 1)
          for (List<Widget> row in _chunkFieldsIntoRows()) Row(children: row),
      ],
    );
  }

  Widget _buildSmallScreenSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          if (fields.length == i + 1 && onFilterTap != null)
            Row(
              children: [
                Expanded(child: _buildSearchField(fields[i])),
                _buildFilterIcon(),
              ],
            )
          else
            _buildSearchField(fields[i]),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 500 && screenWidth < 1000;
    final double width = (isLargeScreen) ? maxContainerWidth : double.infinity;

    return Container(
        width: width,
        padding: EdgeInsets.all(padding),
        child: Builder(
          builder: (context) {
            if (isLargeScreen) {
              return _buildLargeScreenSearchBar();
            }
            if (isMediumScreen) {
              return _buildMediumScreenSearchBar();
            }
            return _buildSmallScreenSearchBar();
          },
        ));
  }
}
