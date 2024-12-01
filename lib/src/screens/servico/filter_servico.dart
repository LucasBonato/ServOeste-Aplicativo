import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class FilterService extends StatelessWidget {
  final TextEditingController addressController = TextEditingController();
  final ValueNotifier<String> equipamentoNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> situacaoNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> filialNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> garantiaNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> horarioNotifier = ValueNotifier<String>('');

  final ValueNotifier<String> dataPrevistaNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> dataEfetivaNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> dataAberturaNotifier = ValueNotifier<String>('');

  FilterService({super.key});

  void applyFilters() {
    final endereco = addressController.text;
    final equipamento = equipamentoNotifier.value;
    final situacao = situacaoNotifier.value;
    final filial = filialNotifier.value;
    final garantia = garantiaNotifier.value;
    final horario = horarioNotifier.value;
    final dataPrevista = dataPrevistaNotifier.value;
    final dataEfetiva = dataEfetivaNotifier.value;
    final dataAbertura = dataAberturaNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context, "Back"),
              ),
              const Text(
                "Voltar",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                  SearchTextField(
                    hint: 'Digite o Endereço do Cliente...',
                    controller: addressController,
                    onChangedAction: (value) {},
                  ),
                  const SizedBox(height: 16.0),
                  CustomSearchDropDown(
                    label: 'Equipamento...',
                    dropdownValues: ['Equipamento 1', 'Equipamento 2'],
                    onChanged: (value) => equipamentoNotifier.value = value,
                  ),
                  const SizedBox(height: 16.0),
                  CustomSearchDropDown(
                    label: 'Situação...',
                    dropdownValues: [
                      'Aguardando Agendamento',
                      'Aguardando Aprovação do Cliente',
                      'Aguardando Atendimento',
                      'Aguardando Cliente Retirar',
                      'Aguardando Orçamento',
                      'Cancelado',
                      'Compra',
                      'Cortesia',
                      'Garantia',
                      'Não Aprovado pelo Cliente',
                      'Não Retira há 3 Meses',
                      'Orçamento Aprovado',
                      'Resolvido',
                      'Sem Defeito',
                      'Fechada'
                    ],
                    onChanged: (value) => situacaoNotifier.value = value,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchDropDown(
                          label: 'Filial...',
                          dropdownValues: ['Osasco', 'Carapicuíba'],
                          onChanged: (value) => filialNotifier.value = value,
                        ),
                      ),
                      Expanded(
                        child: CustomSearchDropDown(
                          label: 'Garantia...',
                          dropdownValues: [
                            'Dentro do período de garantia',
                            'Fora do período de garantia'
                          ],
                          onChanged: (value) => garantiaNotifier.value = value,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Atendimento Previsto...',
                          hint: 'dd/mm/aaaa',
                          mask: Constants.maskData,
                          type: TextInputType.datetime,
                          maxLength: 10,
                          valueNotifier: dataPrevistaNotifier,
                        ),
                      ),
                      Expanded(
                        child: CustomDatePicker(
                          label: 'Data Atendimento Efetivo...',
                          hint: 'dd/mm/aaaa',
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
                          maxLength: 10,
                          valueNotifier: dataAberturaNotifier,
                        ),
                      ),
                      Expanded(
                        child: CustomSearchDropDown(
                          label: 'Horário...',
                          dropdownValues: ['Manhã', 'Tarde'],
                          onChanged: (value) => horarioNotifier.value = value,
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
