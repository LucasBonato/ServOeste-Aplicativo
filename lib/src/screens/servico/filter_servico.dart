import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/src/logic/filtro_servico/filtro_servico_provider.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_field.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/formatters.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class FilterService extends StatelessWidget {
  const FilterService({super.key});

  void applyFilters(BuildContext context) {
    final filter = context.read<FiltroServicoProvider>().filter;

    final filterRequest = ServicoFilterRequest(
      id: filter.id != null && filter.id! > 0 ? filter.id! : null,
      filial: filter.filial ?? '',
      equipamento: filter.equipamento ?? '',
      situacao: filter.situacao ?? '',
      garantia: filter.garantia ?? '',
      dataAtendimentoPrevistoAntes: filter.dataAtendimentoPrevistoAntes,
      dataAtendimentoEfetivoAntes: filter.dataAtendimentoEfetivoAntes,
      dataAberturaAntes: filter.dataAberturaAntes,
      periodo: filter.periodo ?? '',
    );

    context
        .read<ServicoBloc>()
        .add(ServicoLoadingEvent(filterRequest: filterRequest));

    context.read<FiltroServicoProvider>().clearFields();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FiltroServicoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, "Back"),
        ),
        title: const Text("Voltar",
            style: TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: const Color(0xFCFDFDFF),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
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
                  CustomSearchDropDown(
                    label: 'Equipamento...',
                    dropdownValues: Constants.equipamentos,
                    onChanged: (value) {
                      provider.updateFilter(equipamento: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownField(
                    label: 'Situação...',
                    dropdownValues: Constants.situationServiceList,
                    onChanged: (value) {
                      if (value == null || value.isEmpty) {
                        provider.updateFilter(situacao: null);
                      } else {
                        provider.updateFilter(situacao: value);
                      }
                    },
                    valueNotifier:
                        ValueNotifier(provider.filter.situacao ?? ''),
                  ),
                  CustomDropdownField(
                    label: 'Garantia...',
                    dropdownValues: Constants.garantias,
                    onChanged: (value) {
                      if (value == null || value.isEmpty) {
                        provider.updateFilter(garantia: null);
                      } else {
                        provider.updateFilter(garantia: value);
                      }
                    },
                    valueNotifier:
                        ValueNotifier(provider.filter.garantia ?? ''),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomSearchTextField(
                          hint: 'Código...',
                          controller: TextEditingController(
                              text: provider.filter.id != null &&
                                      provider.filter.id! > 0
                                  ? provider.filter.id.toString()
                                  : ''),
                          keyboardType: TextInputType.number,
                          onChangedAction: (value) {
                            final codigoInt =
                                value.isNotEmpty ? int.tryParse(value) : null;
                            provider.updateFilter(codigo: codigoInt);
                          },
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Filial...',
                          dropdownValues: Constants.filiais,
                          onChanged: (value) {
                            if (value == null || value.isEmpty) {
                              provider.updateFilter(filial: null);
                            } else {
                              provider.updateFilter(filial: value);
                            }
                          },
                          valueNotifier:
                              ValueNotifier(provider.filter.filial ?? ''),
                          leftPadding: 4,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Atendimento Previsto...',
                          hint: 'dd/mm/aaaa',
                          mask: InputMasks.maskData,
                          maxLength: 10,
                          hide: true,
                          type: TextInputType.datetime,
                          valueNotifier: ValueNotifier(
                            provider.filter.dataAtendimentoPrevistoAntes != null
                                ? Formatters.applyDateMask(provider
                                    .filter.dataAtendimentoPrevistoAntes!)
                                : '',
                          ),
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsedDate =
                                  DateFormat('dd/MM/yyyy').parse(value);
                              provider.updateFilter(dataPrevista: parsedDate);
                            } else {
                              provider.updateFilter(dataPrevista: null);
                            }
                          },
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Efetiva...',
                          hint: 'dd/mm/aaaa',
                          mask: InputMasks.maskData,
                          maxLength: 10,
                          hide: true,
                          type: TextInputType.datetime,
                          valueNotifier: ValueNotifier(
                            provider.filter.dataAtendimentoEfetivoAntes != null
                                ? Formatters.applyDateMask(provider
                                    .filter.dataAtendimentoEfetivoAntes!)
                                : '',
                          ),
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsedDate =
                                  DateFormat('dd/MM/yyyy').parse(value);
                              provider.updateFilter(dataEfetiva: parsedDate);
                            } else {
                              provider.updateFilter(dataEfetiva: null);
                            }
                          },
                          leftPadding: 4,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Abertura...',
                          hint: 'dd/mm/aaaa',
                          mask: InputMasks.maskData,
                          maxLength: 10,
                          hide: true,
                          type: TextInputType.datetime,
                          valueNotifier: ValueNotifier(
                            provider.filter.dataAberturaAntes != null
                                ? Formatters.applyDateMask(
                                    provider.filter.dataAberturaAntes!)
                                : '',
                          ),
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsedDate =
                                  DateFormat('dd/MM/yyyy').parse(value);
                              provider.updateFilter(dataAbertura: parsedDate);
                            } else {
                              provider.updateFilter(dataAbertura: null);
                            }
                          },
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Horário...',
                          dropdownValues: ['Manhã', 'Tarde'],
                          onChanged: (value) {
                            if (value == null || value.isEmpty) {
                              provider.updateFilter(periodo: null);
                            } else {
                              provider.updateFilter(periodo: value);
                            }
                          },
                          valueNotifier:
                              ValueNotifier(provider.filter.periodo ?? ''),
                          leftPadding: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  ElevatedButton(
                    onPressed: () => applyFilters(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      "Filtrar",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
