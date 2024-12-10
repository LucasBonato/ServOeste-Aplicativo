import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/src/logic/filter_service/filter_service_provider.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
// import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
// import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/formatters.dart';
import 'package:serv_oeste/src/util/input_masks.dart';

class FilterService extends StatelessWidget {
  const FilterService({super.key});

  void applyFilters(BuildContext context) {
    final filter = context.read<FilterServiceProvider>().filter;
    // ServicoSearchEvent(
    //   filterRequest: ServicoFilterRequest(
    //     codigo: filter.codigo,
    //     filial: filter.filial,
    //     equipamento: filter.equipamento,
    //     tecnicoNome: filter.tecnico,
    //     situacao: filter.situacao,
    //     garantia: filter.garantia,
    //     dataAtendimentoPrevistoAntes: filter.dataPrevista,
    //     dataAtendimentoPrevistoDepois: filter.dataEfetiva,
    //     dataAbertura: filter.dataAbertura,
    //     periodo: filter.horario,
    //   ),
    // );
    print(
        "Filtros Aplicados: ${filter.codigo}, ${filter.filial}, ${filter.equipamento}, ${filter.tecnico}, ${filter.situacao}, ${filter.garantia}, ${filter.dataPrevista}, ${filter.dataEfetiva}, ${filter.dataAbertura}, ${filter.horario}");
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilterServiceProvider>();

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
                    onChanged: (value) =>
                        provider.updateFilter(equipamento: value),
                  ),
                  const SizedBox(height: 16),
                  CustomSearchDropDown(
                    label: 'Nome do técnico...',
                    dropdownValues: [],
                    controller:
                        TextEditingController(text: provider.filter.tecnico),
                    onChanged: (value) => provider.updateFilter(tecnico: value),
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownField(
                    label: 'Situação...',
                    dropdownValues: Constants.situationServiceList,
                    onChanged: (value) =>
                        provider.updateFilter(situacao: value!),
                    valueNotifier:
                        ValueNotifier(provider.filter.situacao ?? ''),
                  ),
                  CustomDropdownField(
                    label: 'Garantia...',
                    dropdownValues: Constants.garantias,
                    onChanged: (value) =>
                        provider.updateFilter(garantia: value!),
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
                              text: provider.filter.codigo?.toString() ?? ''),
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
                          onChanged: (value) =>
                              provider.updateFilter(filial: value!),
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
                            provider.filter.dataPrevista != null
                                ? Formatters.applyDateMask(
                                    provider.filter.dataPrevista!)
                                : '',
                          ),
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsedDate =
                                  DateFormat('dd/MM/yyyy').parse(value);
                              provider.updateFilter(dataPrevista: parsedDate);
                            }
                          },
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Atendimento Efetivo...',
                          hint: 'dd/mm/aaaa',
                          mask: InputMasks.maskData,
                          maxLength: 10,
                          hide: true,
                          type: TextInputType.datetime,
                          valueNotifier: ValueNotifier(
                            provider.filter.dataEfetiva != null
                                ? Formatters.applyDateMask(
                                    provider.filter.dataEfetiva!)
                                : '',
                          ),
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              provider.updateFilter(
                                  dataEfetiva:
                                      Formatters.transformDateMask(value));
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
                            provider.filter.dataAbertura != null
                                ? Formatters.applyDateMask(
                                    provider.filter.dataAbertura!)
                                : '',
                          ),
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              provider.updateFilter(
                                  dataAbertura:
                                      Formatters.transformDateMask(value));
                            }
                          },
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Horário...',
                          dropdownValues: ['Manhã', 'Tarde'],
                          onChanged: (value) =>
                              provider.updateFilter(horario: value!),
                          valueNotifier:
                              ValueNotifier(provider.filter.horario ?? ''),
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
