import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/src/logic/filterService/filterServiceProvide.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/input_masks.dart';

class FilterService extends StatelessWidget {
  const FilterService({super.key});

  void applyFilters(BuildContext context) {
    final filter = context.read<FilterServiceProvider>().filter;
    print(
        "Filtros Aplicados: ${filter.endereco}, ${filter.equipamento}, ${filter.situacao}");
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
                    padding: const EdgeInsets.only(bottom: 120.0),
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
                  CustomSearchTextField(
                    hint: 'Digite o Endereço do Cliente...',
                    controller:
                        TextEditingController(text: provider.filter.endereco),
                    onChangedAction: (value) =>
                        provider.updateFilter(endereco: value),
                  ),
                  const SizedBox(height: 20),
                  CustomSearchDropDown(
                    label: 'Equipamento...',
                    dropdownValues: Constants.equipamentos,
                    onChanged: (value) =>
                        provider.updateFilter(equipamento: value),
                  ),
                  const SizedBox(height: 20),
                  CustomDropdownField(
                    label: 'Situação...',
                    dropdownValues: Constants.situationServiceList,
                    onChanged: (value) =>
                        provider.updateFilter(situacao: value!),
                    valueNotifier: ValueNotifier(provider.filter.situacao),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Filial...',
                          dropdownValues: Constants.filiais,
                          onChanged: (value) =>
                              provider.updateFilter(filial: value!),
                          valueNotifier: ValueNotifier(provider.filter.filial),
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Garantia...',
                          dropdownValues: Constants.garantias,
                          onChanged: (value) =>
                              provider.updateFilter(garantia: value!),
                          valueNotifier:
                              ValueNotifier(provider.filter.garantia),
                          leftPadding: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Atendimento Previsto...',
                          hint: 'dd/mm/aaaa',
                          mask: InputMasks.maskData,
                          maxLength: 10,
                          type: TextInputType.datetime,
                          valueNotifier:
                              ValueNotifier(provider.filter.dataPrevista),
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Atendimento Efetivo...',
                          hint: 'dd/mm/aaaa',
                          mask: InputMasks.maskData,
                          maxLength: 10,
                          type: TextInputType.datetime,
                          valueNotifier:
                              ValueNotifier(provider.filter.dataEfetiva),
                          leftPadding: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Abertura...',
                          hint: 'dd/mm/aaaa',
                          mask: InputMasks.maskData,
                          maxLength: 10,
                          type: TextInputType.datetime,
                          valueNotifier:
                              ValueNotifier(provider.filter.dataAbertura),
                          rightPadding: 4,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Horário...',
                          dropdownValues: ['Manhã', 'Tarde'],
                          onChanged: (value) =>
                              provider.updateFilter(horario: value!),
                          valueNotifier: ValueNotifier(provider.filter.horario),
                          leftPadding: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48.0),
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
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
