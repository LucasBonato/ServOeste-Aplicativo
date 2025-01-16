import 'package:serv_oeste/src/components/formFields/date_picker_form_field.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class UpdateServico extends StatefulWidget {
  final int id;

  const UpdateServico({super.key, required this.id});

  @override
  State<UpdateServico> createState() => _UpdateServicoState();
}

class _UpdateServicoState extends State<UpdateServico> {
  late final ServicoBloc _servicoBloc;
  final ServicoForm _servicoUpdateForm = ServicoForm();
  final ClienteForm _clienteUpdateForm = ClienteForm();
  final ServicoValidator _servicoUpdateValidator = ServicoValidator();
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _servicoUpdateForm.setId(widget.id);
    _servicoBloc = context.read<ServicoBloc>();
    _servicoBloc.add(ServicoSearchOneEvent(id: widget.id));
  }

  void _updateServico() {
    if (!_isValidForm()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço atualizado com sucesso!')),
    );
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    _servicoFormKey.currentState?.validate();
    final ValidationResult response =
        _servicoUpdateValidator.validate(_servicoUpdateForm);
    return response.isValid;
  }

  void _handleBackNavigation() {
    _servicoBloc.add(ServicoSearchEvent());
    Navigator.pop(context, "Back");
  }

  void _populateFormWithState(ServicoSearchOneSuccessState state) {
    _servicoUpdateForm.nomeCliente.value = Constants.filiais[0];
    _servicoUpdateForm.nomeTecnico.value = Constants.filiais[0];
    _servicoUpdateForm.equipamento.value = Constants.equipamentos[0];
    _servicoUpdateForm.filial.value = Constants.filiais[0];
    _servicoUpdateForm.horario.value = Constants.dataAtendimento[0];
    _servicoUpdateForm.marca.value = Constants.marcas[0];
    _servicoUpdateForm.garantia.value = Constants.garantias[0];
    _servicoUpdateForm.situacao.value = Constants.situationServiceList[0];
    _servicoUpdateForm.descricao.value = "Descrição Atualizada";
    _servicoUpdateForm.dataAtendimentoPrevisto.value = "2025-01-01";
    _servicoUpdateForm.dataAtendimentoEfetivo.value = "2025-01-02";
    _servicoUpdateForm.dataAtendimentoAbertura.value = "2025-01-03";
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

  Widget _buildClientForm() {
    return Form(
      key: _clienteFormKey,
      child: Column(
        children: [
          CustomSearchDropDownFormField(
            label: 'Nome Cliente*',
            dropdownValues: Constants.filiais,
            leftPadding: 4,
            rightPadding: 4,
            valueNotifier: _servicoUpdateForm.nomeCliente,
            onChanged: _servicoUpdateForm.setNomeCliente,
            validator: _servicoUpdateValidator.byField(
              _servicoUpdateForm,
              'nomeCliente',
            ),
            enabled: false,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      label: "Município",
                      hint: "Município...",
                      type: TextInputType.text,
                      maxLength: 255,
                      hide: true,
                      valueNotifier: _clienteUpdateForm.municipio,
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.municipio.name),
                      rightPadding: 4,
                      leftPadding: 4,
                      enabled: false,
                    ),
                    CustomTextFormField(
                      hint: "Bairro...",
                      label: "Bairro*",
                      type: TextInputType.text,
                      maxLength: 255,
                      hide: true,
                      valueNotifier: _clienteUpdateForm.bairro,
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.bairro.name),
                      rightPadding: 4,
                      leftPadding: 4,
                      enabled: false,
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        label: "Município",
                        hint: "Município...",
                        type: TextInputType.text,
                        maxLength: 255,
                        hide: true,
                        valueNotifier: _clienteUpdateForm.municipio,
                        validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm, ErrorCodeKey.municipio.name),
                        rightPadding: 4,
                        leftPadding: 4,
                        enabled: false,
                      ),
                    ),
                    Expanded(
                      child: CustomTextFormField(
                        hint: "Bairro...",
                        label: "Bairro*",
                        type: TextInputType.text,
                        maxLength: 255,
                        hide: true,
                        valueNotifier: _clienteUpdateForm.bairro,
                        validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm, ErrorCodeKey.bairro.name),
                        rightPadding: 4,
                        leftPadding: 4,
                        enabled: false,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      hint: "Rua...",
                      label: "Rua",
                      type: TextInputType.text,
                      maxLength: 255,
                      hide: true,
                      valueNotifier: _clienteUpdateForm.rua,
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.rua.name),
                      rightPadding: 4,
                      leftPadding: 4,
                      enabled: false,
                    ),
                    CustomTextFormField(
                      hint: "Número...",
                      label: "Número*",
                      type: TextInputType.number,
                      maxLength: 10,
                      hide: true,
                      valueNotifier: _clienteUpdateForm.numero,
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.numero.name),
                      rightPadding: 4,
                      leftPadding: 4,
                      enabled: false,
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                        hint: "Rua...",
                        label: "Rua*",
                        type: TextInputType.text,
                        maxLength: 255,
                        hide: true,
                        valueNotifier: _clienteUpdateForm.rua,
                        validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm, ErrorCodeKey.rua.name),
                        rightPadding: 4,
                        leftPadding: 4,
                        enabled: false,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CustomTextFormField(
                        hint: "Número...",
                        label: "Número*",
                        type: TextInputType.number,
                        maxLength: 10,
                        hide: true,
                        valueNotifier: _clienteUpdateForm.numero,
                        validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm, ErrorCodeKey.numero.name),
                        rightPadding: 4,
                        leftPadding: 4,
                        enabled: false,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          CustomTextFormField(
            hint: "Complemento...",
            label: "Complemento",
            type: TextInputType.text,
            maxLength: 255,
            hide: false,
            rightPadding: 4,
            leftPadding: 4,
            valueNotifier: _clienteUpdateForm.complemento,
            validator: _servicoUpdateValidator.byField(
                _servicoUpdateForm, ErrorCodeKey.complemento.name),
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceForm() {
    return Form(
      key: _servicoFormKey,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchDropDownFormField(
                      label: 'Equipamento*',
                      dropdownValues: Constants.equipamentos,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.equipamento,
                      onChanged: _servicoUpdateForm.setEquipamento,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'equipamento',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomSearchDropDownFormField(
                      label: 'Marca*',
                      dropdownValues: Constants.marcas,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.marca,
                      onChanged: _servicoUpdateForm.setMarca,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'marca',
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomSearchDropDownFormField(
                        label: 'Equipamento*',
                        dropdownValues: Constants.equipamentos,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _servicoUpdateForm.equipamento,
                        onChanged: _servicoUpdateForm.setEquipamento,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'equipamento',
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomSearchDropDownFormField(
                        label: 'Marca*',
                        dropdownValues: Constants.marcas,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _servicoUpdateForm.marca,
                        onChanged: _servicoUpdateForm.setMarca,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'marca',
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          CustomSearchDropDownFormField(
            label: 'Nome Técnico*',
            dropdownValues: Constants.filiais,
            leftPadding: 4,
            rightPadding: 4,
            valueNotifier: _servicoUpdateForm.nomeTecnico,
            onChanged: _servicoUpdateForm.setNomeTecnico,
            validator: _servicoUpdateValidator.byField(
              _servicoUpdateForm,
              'nomeTecnico',
            ),
          ),
          const SizedBox(height: 16),
          CustomDropdownFormField(
            label: 'Filial*',
            dropdownValues: Constants.filiais,
            leftPadding: 4,
            rightPadding: 4,
            valueNotifier: _servicoUpdateForm.filial,
            onChanged: _servicoUpdateForm.setFilial,
            validator: _servicoUpdateValidator.byField(
              _servicoUpdateForm,
              'filial',
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdownFormField(
                      label: 'Garantia',
                      dropdownValues: Constants.garantias,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.garantia,
                      onChanged: _servicoUpdateForm.setGarantia,
                    ),
                    CustomDropdownFormField(
                      label: 'Situação*',
                      dropdownValues: Constants.situationServiceList,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.situacao,
                      onChanged: _servicoUpdateForm.setSituacao,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'situacao',
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomDropdownFormField(
                        label: 'Garantia',
                        dropdownValues: Constants.garantias,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _servicoUpdateForm.garantia,
                        onChanged: _servicoUpdateForm.setGarantia,
                      ),
                    ),
                    Expanded(
                      child: CustomDropdownFormField(
                        label: 'Situação*',
                        dropdownValues: Constants.situationServiceList,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _servicoUpdateForm.situacao,
                        onChanged: _servicoUpdateForm.setSituacao,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'situacao',
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdownFormField(
                      label: 'Horário*',
                      dropdownValues: Constants.dataAtendimento,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.horario,
                      onChanged: _servicoUpdateForm.setHorario,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'horarioPrevisto',
                      ),
                    ),
                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Atendimento Previsto*',
                      mask: [],
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataAtendimentoPrevisto,
                      onChanged: _servicoUpdateForm.setDataAtendimentoPrevisto,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'dataAtendimentoPrevisto',
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomDropdownFormField(
                        label: 'Horário*',
                        dropdownValues: Constants.dataAtendimento,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _servicoUpdateForm.horario,
                        onChanged: _servicoUpdateForm.setHorario,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'horarioPrevisto',
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomDatePickerFormField(
                        hint: 'dd/mm/yyyy',
                        label: 'Data Atendimento Previsto*',
                        mask: [],
                        maxLength: 10,
                        hide: true,
                        leftPadding: 4,
                        rightPadding: 4,
                        type: TextInputType.datetime,
                        valueNotifier:
                            _servicoUpdateForm.dataAtendimentoPrevisto,
                        onChanged:
                            _servicoUpdateForm.setDataAtendimentoPrevisto,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'dataAtendimentoPrevisto',
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Efetiva',
                      mask: [],
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                      onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'dataAtendimentoEfetivo',
                      ),
                    ),
                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data de Abertura',
                      mask: [],
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataAtendimentoAbertura,
                      onChanged: _servicoUpdateForm.setDataAtendimentoAbertura,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'dataAtendimentoAbertura',
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomDatePickerFormField(
                        hint: 'dd/mm/yyyy',
                        label: 'Data Efetiva',
                        mask: [],
                        maxLength: 10,
                        hide: true,
                        leftPadding: 4,
                        rightPadding: 4,
                        type: TextInputType.datetime,
                        valueNotifier:
                            _servicoUpdateForm.dataAtendimentoEfetivo,
                        onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'dataAtendimentoEfetivo',
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomDatePickerFormField(
                        hint: 'dd/mm/yyyy',
                        label: 'Data de Abertura',
                        mask: [],
                        maxLength: 10,
                        hide: true,
                        leftPadding: 4,
                        rightPadding: 4,
                        type: TextInputType.datetime,
                        valueNotifier:
                            _servicoUpdateForm.dataAtendimentoAbertura,
                        onChanged:
                            _servicoUpdateForm.setDataAtendimentoAbertura,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'dataAtendimentoAbertura',
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      label: 'Valor Serviço',
                      hint: 'Valor Serviço...',
                      leftPadding: 4,
                      rightPadding: 4,
                      maxLength: 8,
                      hide: true,
                      type: TextInputType.number,
                      valueNotifier: _servicoUpdateForm.equipamento,
                      onChanged: _servicoUpdateForm.setEquipamento,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'equipamento',
                      ),
                    ),
                    CustomTextFormField(
                      label: 'Valor Peças',
                      hint: 'Valor Peças...',
                      leftPadding: 4,
                      rightPadding: 4,
                      maxLength: 8,
                      hide: true,
                      type: TextInputType.number,
                      valueNotifier: _servicoUpdateForm.equipamento,
                      onChanged: _servicoUpdateForm.setEquipamento,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'equipamento',
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        label: 'Valor Serviço',
                        hint: 'Valor Serviço...',
                        leftPadding: 4,
                        rightPadding: 4,
                        maxLength: 8,
                        hide: true,
                        type: TextInputType.number,
                        valueNotifier: _servicoUpdateForm.equipamento,
                        onChanged: _servicoUpdateForm.setEquipamento,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'equipamento',
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomTextFormField(
                        label: 'Valor Peças',
                        hint: 'Valor Peças...',
                        leftPadding: 4,
                        rightPadding: 4,
                        maxLength: 8,
                        hide: true,
                        type: TextInputType.number,
                        valueNotifier: _servicoUpdateForm.equipamento,
                        onChanged: _servicoUpdateForm.setEquipamento,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'equipamento',
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdownFormField(
                      label: 'Forma de Pagamento',
                      dropdownValues: Constants.formasPagamento,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.equipamento,
                      onChanged: _servicoUpdateForm.setEquipamento,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'equipamento',
                      ),
                    ),
                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Encerramento',
                      mask: [],
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                      onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'dataAtendimentoEfetivo',
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomDropdownFormField(
                        label: 'Forma de Pagamento',
                        dropdownValues: Constants.formasPagamento,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _servicoUpdateForm.equipamento,
                        onChanged: _servicoUpdateForm.setEquipamento,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'equipamento',
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomDatePickerFormField(
                        hint: 'dd/mm/yyyy',
                        label: 'Data Encerramento',
                        mask: [],
                        maxLength: 10,
                        hide: true,
                        leftPadding: 4,
                        rightPadding: 4,
                        type: TextInputType.datetime,
                        valueNotifier:
                            _servicoUpdateForm.dataAtendimentoEfetivo,
                        onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'dataAtendimentoEfetivo',
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      label: 'Valor Comissão',
                      hint: 'Valor Comissão...',
                      leftPadding: 4,
                      rightPadding: 4,
                      maxLength: 8,
                      hide: true,
                      type: TextInputType.number,
                      valueNotifier: _servicoUpdateForm.equipamento,
                      onChanged: _servicoUpdateForm.setEquipamento,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'equipamento',
                      ),
                    ),
                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Pgto. comissão',
                      mask: [],
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                      onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'dataAtendimentoEfetivo',
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        label: 'Valor Comissão',
                        hint: 'Valor Comissão...',
                        leftPadding: 4,
                        rightPadding: 4,
                        maxLength: 8,
                        hide: true,
                        type: TextInputType.number,
                        valueNotifier: _servicoUpdateForm.equipamento,
                        onChanged: _servicoUpdateForm.setEquipamento,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'equipamento',
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomDatePickerFormField(
                        hint: 'dd/mm/yyyy',
                        label: 'Data Pgto. comissão',
                        mask: [],
                        maxLength: 10,
                        hide: true,
                        leftPadding: 4,
                        rightPadding: 4,
                        type: TextInputType.datetime,
                        valueNotifier:
                            _servicoUpdateForm.dataAtendimentoEfetivo,
                        onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                        validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm,
                          'dataAtendimentoEfetivo',
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          CustomTextFormField(
            hint: "Descrição...",
            label: "Descrição*",
            type: TextInputType.multiline,
            maxLength: 255,
            maxLines: 3,
            minLines: 1,
            hide: false,
            leftPadding: 4,
            rightPadding: 4,
            valueNotifier: _servicoUpdateForm.descricao,
            validator: _servicoUpdateValidator.byField(
                _servicoUpdateForm, ErrorCodeKey.descricao.name),
            onChanged: _servicoUpdateForm.setDescricao,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _handleBackNavigation,
        ),
        title: const Text(
          "Voltar",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: const Color(0xFCFDFDFF),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (String value) {
                // final actionsMap = {
                //   'relatorioVisitas': '',
                //   'gerarOrcamento': '',
                //   'gerarRecibo': '',
                // };
                // actionsMap[value]?.call();
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'relatorioVisitas',
                  child: Text('Imprimir Relatório de Visitas'),
                ),
                PopupMenuItem<String>(
                  value: 'gerarOrcamento',
                  child: Text('Gerar Orçamento'),
                ),
                PopupMenuItem<String>(
                  value: 'gerarRecibo',
                  child: Text('Gerar Recibo'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<ServicoBloc, ServicoState>(
        bloc: _servicoBloc,
        buildWhen: (previousState, state) {
          if (state is ServicoSearchOneSuccessState) {
            _populateFormWithState(state);
            return true;
          }
          return false;
        },
        builder: (context, state) {
          return (state is ServicoSearchSuccessState)
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior()
                            .copyWith(overscroll: false, scrollbars: false),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 48),
                              const Text(
                                "Atualizar Serviço",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 48),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 800) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              _buildCard(_buildClientForm(),
                                                  'Cliente'),
                                              const SizedBox(height: 8),
                                              BuildFieldLabels(
                                                  isClientAndService: false),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 4,
                                          child: _buildCard(
                                              _buildServiceForm(), 'Serviço'),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        _buildCard(
                                            _buildClientForm(), 'Cliente'),
                                        const SizedBox(height: 16),
                                        _buildCard(
                                            _buildServiceForm(), 'Serviço'),
                                        const SizedBox(height: 8),
                                        BuildFieldLabels(
                                            isClientAndService: false),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 750),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BlocListener<ServicoBloc, ServicoState>(
                                      bloc: _servicoBloc,
                                      listener: (context, state) {
                                        if (state
                                            is ServicoUpdateSuccessState) {
                                          _handleBackNavigation();
                                        } else if (state is ServicoErrorState) {
                                          ErrorEntity error = state.error;

                                          _servicoUpdateValidator
                                              .applyBackendError(error);
                                          _servicoFormKey.currentState
                                              ?.validate();
                                          _servicoUpdateValidator
                                              .cleanExternalErrors();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "[ERROR] Informação(ões) inválida(s) ao Atualizar o Serviço.",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: _updateServico,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF8BB0DD),
                                              minimumSize: const Size(
                                                  double.infinity, 48),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 18),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              "Ver Histórico de Atendimento",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: _updateServico,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF007BFF),
                                              minimumSize: const Size(
                                                  double.infinity, 48),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 18),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              "Atualizar Serviço",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}
