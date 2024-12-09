import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/screens/servico/table_tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/input_masks.dart';

class CreateServicoAndCliente extends StatefulWidget {
  const CreateServicoAndCliente({super.key});

  @override
  State<CreateServicoAndCliente> createState() =>
      _CreateServicoAndClienteState();
}

class _CreateServicoAndClienteState extends State<CreateServicoAndCliente> {
  final ClienteForm _clienteForm = ClienteForm();
  final ClienteValidator _clienteValidator = ClienteValidator();

  final ServicoForm _servicoForm = ServicoForm();
  final ServicoValidator _servicoValidator = ServicoValidator();

  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context, "Back"),
              )
            ],
          ),
        ),
        title: const Text(
          "Voltar",
          style: TextStyle(color: Colors.black, fontSize: 16),
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
                    const SizedBox(height: 48),
                    isMobile
                        ? Column(
                            children: [
                              _buildCard(_buildClientForm(), 'Cliente'),
                              const SizedBox(height: 16),
                              _buildCard(_buildServiceForm(), 'Serviço'),
                              const SizedBox(height: 8),
                              _buildFieldLabels(context),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildCard(_buildClientForm(), 'Cliente'),
                                    const SizedBox(height: 8),
                                    _buildFieldLabels(context),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child:
                                    _buildCard(_buildServiceForm(), 'Serviço'),
                              ),
                            ],
                          ),
                    const SizedBox(height: 48),
                    _buildButton('Verificar disponibilidade', Colors.blue, () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const TableTecnicosModal();
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildButton('Adicionar Cliente e Serviço', Colors.blue,
                        () {
                      final bool isClienteValid =
                          _clienteFormKey.currentState?.validate() ?? false;
                      final bool isServicoValid =
                          _servicoFormKey.currentState?.validate() ?? false;

                      if (isClienteValid && isServicoValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Cliente e Serviço adicionados com sucesso!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Por favor, corrija os erros nos formulários.'),
                          ),
                        );
                      }
                    }),
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

  Widget _buildFieldLabels(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "* - Campos obrigatórios",
            style: TextStyle(
              fontSize:
                  (MediaQuery.of(context).size.width * 0.01).clamp(12.0, 14.0),
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "** - Preencha ao menos um destes campos",
            style: TextStyle(
              fontSize:
                  (MediaQuery.of(context).size.width * 0.01).clamp(12.0, 14.0),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientForm() {
    return Column(
      children: [
        CustomSearchDropDown(
          label: "Nome do Cliente*",
          dropdownValues: const [
            "Jefferson Lima",
            "Rio de Azevedo",
            "Belo Luis",
            "Curitiba Bianco"
          ], // TODO: fazer com que o nome dos clientes já cadastrados apareçam aqui
          maxLength: 40,
          hide: false,
          valueNotifier: _clienteForm.nome,
          validator: _clienteValidator.byField(_clienteForm, "nome"),
          onChanged: _clienteForm.setNome,
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          hint: "(99) 9999-9999",
          label: "Telefone Fixo**",
          type: TextInputType.phone,
          maxLength: 14,
          hide: true,
          masks: InputMasks.maskTelefoneFixo,
          valueNotifier: _clienteForm.telefoneFixo,
          validator: _clienteValidator.byField(_clienteForm, "telefoneFixo"),
          onChanged: _clienteForm.setTelefoneFixo,
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          hint: "(99) 99999-9999",
          label: "Telefone Celular**",
          type: TextInputType.phone,
          maxLength: 15,
          hide: true,
          masks: InputMasks.maskCelular,
          valueNotifier: _clienteForm.telefoneCelular,
          validator: _clienteValidator.byField(_clienteForm, "telefoneCelular"),
          onChanged: _clienteForm.setTelefoneCelular,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                hint: "00000-000",
                label: "CEP",
                rightPadding: 8,
                type: TextInputType.number,
                maxLength: 9,
                hide: true,
                masks: [
                  MaskTextInputFormatter(mask: '#####-###'),
                ],
                valueNotifier: _clienteForm.cep,
                validator: _clienteValidator.byField(_clienteForm, "cep"),
                onChanged: _clienteForm.setCep,
              ),
            ),
            Expanded(
              child: CustomSearchDropDown(
                label: "Município*",
                dropdownValues: Constants.municipios,
                leftPadding: 0,
                maxLength: 20,
                controller: TextEditingController(),
                valueNotifier: _clienteForm.municipio,
                validator: _clienteValidator.byField(_clienteForm, "municipio"),
                onChanged: _clienteForm.setMunicipio,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextFormField(
                hint: "Rua...",
                label: "Rua*",
                rightPadding: 8,
                type: TextInputType.text,
                maxLength: 255,
                hide: true,
                valueNotifier: _clienteForm.rua,
                validator: _clienteValidator.byField(_clienteForm, "rua"),
                onChanged: _clienteForm.setRua,
              ),
            ),
            Expanded(
              flex: 1,
              child: CustomTextFormField(
                hint: "Número...",
                label: "Número*",
                leftPadding: 0,
                type: TextInputType.number,
                maxLength: 10,
                hide: true,
                valueNotifier: _clienteForm.numero,
                validator: _clienteValidator.byField(_clienteForm, "numero"),
                onChanged: _clienteForm.setNumero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          hint: "Complemento...",
          label: "Complemento",
          type: TextInputType.text,
          maxLength: 255,
          hide: false,
          valueNotifier: _clienteForm.complemento,
          onChanged: _clienteForm.setComplemento,
        ),
      ],
    );
  }

  Widget _buildServiceForm() {
    const double spacing = 24;

    return Column(
      children: [
        CustomSearchDropDown(
          dropdownValues: Constants.equipamentos,
          valueNotifier: _servicoForm.equipamento,
          label: "Equipamento*",
          validator: _servicoValidator.byField(_servicoForm, "equipamento"),
          onChanged: _servicoForm.setEquipamento,
        ),
        const SizedBox(height: spacing),
        CustomSearchDropDown(
          dropdownValues: Constants.marcas,
          valueNotifier: _servicoForm.marca,
          label: "Marca*",
          validator: _servicoValidator.byField(_servicoForm, "marca"),
          onChanged: _servicoForm.setMarca,
        ),
        const SizedBox(height: spacing),
        CustomDropdownField(
          dropdownValues: Constants.filiais,
          valueNotifier: _servicoForm.filial,
          label: "Filial*",
          validator: _servicoValidator.byField(_servicoForm, "filial"),
          onChanged: _servicoForm.setFilial,
        ),
        const SizedBox(height: 6),
        CustomTextFormField(
          hint: "Nome do Técnico...",
          label: "Nome do Técnico*",
          type: TextInputType.text,
          maxLength: 50,
          hide: false,
          valueNotifier: _servicoForm.tecnico,
          validator: _servicoValidator.byField(_servicoForm, "tecnico"),
          onChanged: _servicoForm.setTecnico,
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: CustomDatePicker(
                label: "Data Atendimento Previsto*",
                hint: 'dd/mm/aaaa',
                rightPadding: 8,
                mask: InputMasks.maskData,
                type: TextInputType.datetime,
                maxLength: 10,
                hide: true,
                valueNotifier: _servicoForm.dataPrevista,
                validator:
                    _servicoValidator.byField(_servicoForm, "dataPrevista"),
                onChanged: _servicoForm.setDataPrevista,
              ),
            ),
            Expanded(
              flex: 1,
              child: CustomDropdownField(
                dropdownValues: Constants.dataAtendimento,
                label: "Horário*",
                leftPadding: 0,
                valueNotifier: _servicoForm.horario,
                validator: _servicoValidator.byField(_servicoForm, "horario"),
                onChanged: _servicoForm.setHorario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        CustomTextFormField(
          hint: "Descrição...",
          label: "Descrição*",
          type: TextInputType.multiline,
          maxLength: 255,
          maxLines: 3,
          hide: false,
          valueNotifier: _servicoForm.descricao,
          validator: _servicoValidator.byField(_servicoForm, "descricao"),
          onChanged: _servicoForm.setDescricao,
        ),
      ],
    );
  }
}
