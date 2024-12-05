import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class FilterService extends StatelessWidget {
  final TextEditingController addressController = TextEditingController();

  final ValueNotifier<String?> equipamentoNotifier = ValueNotifier<String?>('');
  final ValueNotifier<String?> situacaoNotifier = ValueNotifier<String?>('');
  final ValueNotifier<String?> filialNotifier = ValueNotifier<String?>('');
  final ValueNotifier<String?> garantiaNotifier = ValueNotifier<String?>('');
  final ValueNotifier<String?> horarioNotifier = ValueNotifier<String?>('');

  final ValueNotifier<String> dataPrevistaNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> dataEfetivaNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> dataAberturaNotifier = ValueNotifier<String>('');

  FilterService({super.key});

  void applyFilters() {
    // final endereco = addressController.text;
    // final equipamento = equipamentoNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, "Back"),
          ),
        ),
        title: const Text(
          "Voltar",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
                    controller: addressController,
                    onChangedAction: (value) {},
                  ),
                  const SizedBox(height: 16.0),
                  CustomSearchDropDown(
                    label: 'Equipamento...',
                    dropdownValues: Constants.equipamentos,
                    onChanged: (value) => equipamentoNotifier.value = value,
                    valueNotifier: equipamentoNotifier,
                  ),
                  const SizedBox(height: 16.0),
                  CustomDropdownField(
                    label: 'Situação...',
                    dropdownValues: Constants.situationServiceList,
                    onChanged: (value) => situacaoNotifier.value = value,
                    valueNotifier: situacaoNotifier,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Filial...',
                          dropdownValues: Constants.filiais,
                          rightPadding: 4,
                          onChanged: (value) => filialNotifier.value = value,
                          valueNotifier: filialNotifier,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownField(
                          label: 'Garantia...',
                          dropdownValues: Constants.garantias,
                          leftPadding: 4,
                          onChanged: (value) => garantiaNotifier.value = value,
                          valueNotifier: garantiaNotifier,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CustomDatePicker(
                          label: 'Data Atendimento Previsto...',
                          hint: 'dd/mm/aaaa',
                          mask: Constants.maskData,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          maxLength: 10,
                          valueNotifier: dataPrevistaNotifier,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: CustomDatePicker(
                          label: 'Data Atendimento Efetivo...',
                          hint: 'dd/mm/aaaa',
                          leftPadding: 4,
                          mask: Constants.maskData,
                          type: TextInputType.datetime,
                          maxLength: 10,
                          valueNotifier: dataEfetivaNotifier,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Abertura...',
                          hint: 'dd/mm/aaaa',
                          mask: Constants.maskData,
                          type: TextInputType.datetime,
                          rightPadding: 4,
                          maxLength: 10,
                          valueNotifier: dataAberturaNotifier,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownField(
                          leftPadding: 4,
                          label: 'Horário...',
                          dropdownValues: ['Manhã', 'Tarde'],
                          onChanged: (value) => horarioNotifier.value = value,
                          valueNotifier: horarioNotifier,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 58.0),
                  ElevatedButton(
                    onPressed: applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Filtrar',
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
