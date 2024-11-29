import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';

class CreateServicoAndCliente extends StatefulWidget {
  const CreateServicoAndCliente({super.key});

  @override
  State<CreateServicoAndCliente> createState() =>
      _CreateServicoAndClienteState();
}

class _CreateServicoAndClienteState extends State<CreateServicoAndCliente> {
  final TextEditingController dataPrevistaController = TextEditingController();
  final TextEditingController horarioController = TextEditingController();

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
        backgroundColor: Color(0xFCFDFDFF),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 42),
                    const Text(
                      'Adicionar Cliente/Serviço',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 36),
                    isMobile
                        ? Column(
                            children: [
                              _buildCard(_buildClientForm(), 'Cliente'),
                              const SizedBox(height: 16),
                              _buildCard(_buildServiceForm(), 'Serviço'),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child:
                                    _buildCard(_buildClientForm(), 'Cliente'),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child:
                                    _buildCard(_buildServiceForm(), 'Serviço'),
                              ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    _buildButton(
                        'Verificar disponibilidade', Colors.blue, () {}),
                    const SizedBox(height: 16),
                    _buildButton('Adicionar Serviço', Colors.blue, () {}),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(Widget child, String title) {
    return Align(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEAE6E5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(600, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildClientForm() {
    return Column(
      children: [
        CustomTextFormField(
          valueNotifier: ValueNotifier(""),
          maxLength: 50,
          label: 'Nome do Cliente*',
          hint: 'Nome do Cliente...',
          hide: false,
          type: TextInputType.text,
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          valueNotifier: ValueNotifier(""),
          maxLength: 15,
          label: 'Telefone Fixo**',
          hint: '(99) 9999-9999',
          hide: false,
          masks: [
            MaskTextInputFormatter(mask: '(##) ####-####'),
          ],
          type: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          valueNotifier: ValueNotifier(""),
          maxLength: 15,
          label: 'Telefone Celular**',
          hint: '(99) 99999-9999',
          hide: false,
          masks: [
            MaskTextInputFormatter(mask: '(##) #####-####'),
          ],
          type: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                valueNotifier: ValueNotifier(""),
                maxLength: 9,
                label: 'CEP',
                hint: '00000-000',
                hide: false,
                masks: [
                  MaskTextInputFormatter(mask: '#####-###'),
                ],
                type: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextFormField(
                valueNotifier: ValueNotifier(""),
                maxLength: 50,
                label: 'Município*',
                hint: 'Município...',
                hide: false,
                type: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomTextFormField(
                valueNotifier: ValueNotifier(""),
                maxLength: 100,
                label: 'Rua*',
                hint: 'Rua...',
                hide: false,
                type: TextInputType.text,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: CustomTextFormField(
                valueNotifier: ValueNotifier(""),
                maxLength: 6,
                label: 'Número*',
                hint: 'Número...',
                hide: false,
                type: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          valueNotifier: ValueNotifier(""),
          maxLength: 100,
          label: 'Complemento',
          hint: 'Complemento...',
          hide: false,
          type: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildServiceForm() {
    return Column(
      children: [
        CustomDropdownField(
          dropdownValues: ['Equipamento 1', 'Equipamento 2'],
          valueNotifier: ValueNotifier(""),
          label: 'Equipamento*',
          onChanged: (value) {
            // Lógica para manipular o valor selecionado
          },
        ),
        const SizedBox(height: 8),
        CustomDropdownField(
          dropdownValues: ['Marca 1', 'Marca 2'],
          valueNotifier: ValueNotifier(""),
          label: 'Marca*',
          onChanged: (value) {
            // Lógica para manipular o valor selecionado
          },
        ),
        const SizedBox(height: 8),
        CustomDropdownField(
          dropdownValues: ['Filial 1', 'Filial 2'],
          valueNotifier: ValueNotifier(""),
          label: 'Filial*',
          onChanged: (value) {
            // Lógica para manipular o valor selecionado
          },
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          valueNotifier: ValueNotifier(""),
          maxLength: 50,
          label: 'Nome do Técnico*',
          hint: 'Nome do Técnico...',
          hide: false,
          type: TextInputType.text,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 80,
                child: CustomDatePicker(
                  controller: dataPrevistaController,
                  label: 'Data Atendimento Previsto*',
                  hint: 'dd/mm/aaaa',
                  mask: '##/##/####',
                  errorMessage: 'Data inválida',
                  type: TextInputType.datetime,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                height: 80,
                child: CustomDropdownField(
                  dropdownValues: ['Manhã', 'Tarde'],
                  valueNotifier: ValueNotifier(""),
                  label: 'Horário*',
                  onChanged: (value) {
                    // Lógica para manipular o valor selecionado
                    horarioController.text = value!;
                  },
                ),
              ),
            ),
          ],
        ),
        CustomTextFormField(
          valueNotifier: ValueNotifier(""),
          maxLength: 200,
          label: 'Descrição*',
          hint: 'Descrição...',
          hide: false,
          type: TextInputType.multiline,
          maxLines: 3,
        ),
      ],
    );
  }
}
