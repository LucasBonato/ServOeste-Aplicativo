import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serv_oeste/core/constants/constants.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter_form.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/shared/utils/formatters/input_masks.dart';
import 'package:serv_oeste/shared/widgets/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/date_picker_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_input_field.dart';
import 'package:serv_oeste/shared/widgets/screen/base_entity_form.dart';
import 'package:serv_oeste/shared/widgets/screen/base_form_screen.dart';

class ServicoFilterFormWidget extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final ServicoBloc bloc;
  final String title;
  final String submitText;
  final ServicoFilterForm form;

  const ServicoFilterFormWidget({
    super.key,
    required this.bloc,
    required this.title,
    required this.submitText,
    required this.form,
    this.formKey,
  });

  DateTime? _parseDate(String date) {
    if (date.isEmpty) return null;
    return DateFormat("dd/MM/yyyy").parse(date);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = this.formKey ?? GlobalKey<FormState>();

    return BaseFormScreen(
      title: title,
      shouldActivateEvent: false,
      child: BaseEntityForm<ServicoBloc, ServicoState>(
        bloc: bloc,
        formKey: formKey,
        submitText: submitText,
        getSuccessMessage: (_) => "Filtro aplicado com sucesso",
        isLoading: (state) => state is ServicoLoadingState,
        isSuccess: (state) => state is ServicoSearchSuccessState,
        isError: (state) => state is ServicoErrorState,
        onSubmit: () async {
          final ServicoFilter newFilter = ServicoFilter(
            id: form.codigo.value != null && form.codigo.value! > 0 ? form.codigo.value! : null,
            filial: form.filial.value.isNotEmpty ? form.filial.value : null,
            equipamento: form.equipamento.value.isNotEmpty ? form.equipamento.value : null,
            situacao: form.situacao.value.isNotEmpty ? form.situacao.value : null,
            garantia: form.garantia.value.isNotEmpty ? form.garantia.value : null,
            dataAtendimentoPrevistoAntes: _parseDate(form.dataAtendimentoPrevistoAntes.value),
            dataAtendimentoEfetivoAntes: _parseDate(form.dataAtendimentoEfetivoAntes.value),
            dataAberturaAntes: _parseDate(form.dataAberturaAntes.value),
            periodo: form.periodo.value.isNotEmpty ? form.periodo.value : null,
          );

          bloc.add(ServicoSearchEvent(filter: newFilter));
        },
        buildFields: () => [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/servOeste.png',
                width: 415,
                height: 75,
                fit: BoxFit.contain,
              ),
            ),
          ),
          DropdownSearchInputField(
            hint: "Equipamento...",
            onChanged: form.setEquipamento,
            valueNotifier: form.equipamento,
            dropdownValues: Constants.equipamentos,
          ),
          DropdownInputField(
            hint: "Situação...",
            valueNotifier: form.situacao,
            onChanged: form.setSituacao,
            dropdownValues: Constants.situationServiceList,
          ),
          DropdownInputField(
            hint: "Garantia...",
            valueNotifier: form.garantia,
            onChanged: form.setGarantia,
            dropdownValues: Constants.garantias,
          ),
          Wrap(
            runSpacing: 8,
            children: [
              CustomSearchTextFormField(
                hint: "Código...",
                leftPadding: 4,
                rightPadding: 4,
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: form.codigo.value != null && form.codigo.value! > 0 ? form.codigo.value.toString() : ""),
                onChangedAction: form.setCodigo,
              ),
              CustomDropdownFormField(
                label: "Filial...",
                dropdownValues: Constants.filiais,
                leftPadding: 4,
                rightPadding: 4,
                onChanged: form.setFilial,
                valueNotifier: form.filial,
              ),
            ],
          ),
          Wrap(
            runSpacing: 8,
            children: [
              CustomDatePickerFormField(
                label: "Data Prevista...",
                hint: "dd/mm/aaaa",
                mask: InputMasks.data,
                maxLength: 10,
                hide: true,
                rightPadding: 4,
                leftPadding: 4,
                type: TextInputType.datetime,
                valueNotifier: form.dataAtendimentoPrevistoAntes,
                onChanged: form.setDataAtendimentoPrevistoAntes,
                allowPastDates: true,
              ),
              CustomDatePickerFormField(
                label: "Data Efetiva...",
                hint: "dd/mm/aaaa",
                mask: InputMasks.data,
                maxLength: 10,
                hide: true,
                rightPadding: 4,
                leftPadding: 4,
                type: TextInputType.datetime,
                valueNotifier: form.dataAtendimentoEfetivoAntes,
                onChanged: form.setDataAtendimentoEfetivoAntes,
                allowPastDates: true,
              ),
            ]
          ),
          Wrap(
            runSpacing: 8,
            children: [
              CustomDatePickerFormField(
                label: "Data Abertura...",
                hint: "dd/mm/aaaa",
                mask: InputMasks.data,
                maxLength: 10,
                hide: true,
                rightPadding: 4,
                leftPadding: 4,
                type: TextInputType.datetime,
                valueNotifier: form.dataAberturaAntes,
                onChanged: form.setDataAberturaAntes,
                allowPastDates: true,
              ),
              CustomDropdownFormField(
                label: "Horário...",
                dropdownValues: Constants.horarioPrevisto,
                rightPadding: 4,
                leftPadding: 4,
                onChanged: form.setPeriodo,
                valueNotifier: form.periodo,
              ),
            ]
          )
        ],
      ),
    );
  }
}
