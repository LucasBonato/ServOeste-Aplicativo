import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/date_picker_form_field.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/components/screen/card_builder_form.dart';
import 'package:serv_oeste/src/components/screen/elevated_form_button.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

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
    final ValidationResult response = _servicoUpdateValidator.validate(_servicoUpdateForm);
    return response.isValid;
  }

  void _handleBackNavigation() {
    _servicoBloc.add(ServicoLoadingEvent(filterRequest: ServicoFilterRequest()));
    Navigator.pop(context, "Back");
  }

  void _handleError(ServicoErrorState state) {
    ErrorEntity error = state.error;

    _servicoUpdateValidator.applyBackendError(error);
    _servicoFormKey.currentState?.validate();
    _servicoUpdateValidator.cleanExternalErrors();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "[ERROR] Informação(ões) inválida(s) ao Atualizar o Serviço.",
        ),
      ),
    );
  }

  void _populateFormWithState(ServicoSearchOneSuccessState state) {
    _servicoUpdateForm.setNomeCliente(state.servico.nomeCliente);
    _servicoUpdateForm.setEquipamento(state.servico.equipamento);
    _servicoUpdateForm.setMarca(state.servico.marca);
    _servicoUpdateForm.setNomeTecnico(state.servico.nomeTecnico);
    _servicoUpdateForm.setFilial(state.servico.filial);
    _servicoUpdateForm.setGarantiaBool(state.servico.garantia);
    _servicoUpdateForm.setSituacao(state.servico.situacao);
    _servicoUpdateForm.setHorario(state.servico.horarioPrevisto);
    _servicoUpdateForm.setDataAtendimentoPrevistoDate(state.servico.dataAtendimentoPrevisto);
    _servicoUpdateForm.setDataAtendimentoEfetivoDate(state.servico.dataAtendimentoEfetivo);
    _servicoUpdateForm.setDataAtendimentoAberturaDate(state.servico.dataAtendimentoAbertura);
    _servicoUpdateForm.setValor(state.servico.valor.toString());
    _servicoUpdateForm.setValorPecas(state.servico.valorPecas.toString());
    _servicoUpdateForm.setFormaPagamento(state.servico.formaPagamento);
    _servicoUpdateForm.setDataFechamentoDate(state.servico.dataFechamento);
    _servicoUpdateForm.setValorComissao(state.servico.valorComissao.toString());
    _servicoUpdateForm.setDataPagamentoComissaoDate(state.servico.dataPagamentoComissao);
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
            hide: true,
            valueNotifier: _servicoUpdateForm.nomeCliente,
            onChanged: _servicoUpdateForm.setNomeCliente,
            validator: _servicoUpdateValidator.byField(
              _servicoUpdateForm,
              'nomeCliente',
            ),
            enabled: false,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  children: [
                    CustomTextFormField(
                      label: "Município",
                      hint: "Município...",
                      type: TextInputType.text,
                      maxLength: 255,
                      hide: true,
                      valueNotifier: _clienteUpdateForm.municipio,
                      validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.municipio.name),
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
                      validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.bairro.name),
                      rightPadding: 4,
                      leftPadding: 4,
                      enabled: false,
                    ),
                    CustomTextFormField(
                      hint: "Rua...",
                      label: "Rua",
                      type: TextInputType.text,
                      maxLength: 255,
                      hide: true,
                      valueNotifier: _clienteUpdateForm.rua,
                      validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.rua.name),
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
                      validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.numero.name),
                      rightPadding: 4,
                      leftPadding: 4,
                      enabled: false,
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          label: "Município",
                          hint: "Município...",
                          type: TextInputType.text,
                          maxLength: 255,
                          hide: true,
                          valueNotifier: _clienteUpdateForm.municipio,
                          validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.municipio.name),
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
                          validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.bairro.name),
                          rightPadding: 4,
                          leftPadding: 4,
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                  Row(
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
                          validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.rua.name),
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
                          validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.numero.name),
                          rightPadding: 4,
                          leftPadding: 4,
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                ],
              );
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
            validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.complemento.name),
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
                      hide: true,
                    ), // Equipamento

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
                      hide: true,
                    ), // Marca

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
                      hide: true,
                    ), // Nome Técnico

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
                    ), // Filial
                    
                    CustomDropdownFormField(
                      label: 'Garantia',
                      dropdownValues: Constants.garantias,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.garantia,
                      onChanged: _servicoUpdateForm.setGarantia,
                    ), // Garantia
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
                    ), // Situação
                    
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
                    ), // Horário
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
                    ), // Data Atendimento Previsto
                    
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
                    ), // Data Atendimento Efetivo
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
                    ), // Data Abertura -- Tirar
                    
                    CustomTextFormField(
                      label: 'Valor Serviço',
                      hint: 'Valor Serviço...',
                      leftPadding: 4,
                      rightPadding: 4,
                      maxLength: 8,
                      hide: true,
                      type: TextInputType.numberWithOptions(decimal: true),
                      valueNotifier: _servicoUpdateForm.valor,
                      onChanged: _servicoUpdateForm.setValor,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'valor',
                      ),
                      inputFormatters: InputMasks.maskAlphanumericLetters,
                    ), // Valor
                    CustomTextFormField(
                      label: 'Valor Peças',
                      hint: 'Valor Peças...',
                      leftPadding: 4,
                      rightPadding: 4,
                      maxLength: 8,
                      hide: true,
                      type: TextInputType.numberWithOptions(decimal: true),
                      valueNotifier: _servicoUpdateForm.valorPecas,
                      onChanged: _servicoUpdateForm.setValorPecas,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'valorPecas',
                      ),
                      inputFormatters: InputMasks.maskAlphanumericLetters,
                    ), // Valor Peças
                    
                    CustomDropdownFormField(
                      label: 'Forma de Pagamento',
                      dropdownValues: Constants.formasPagamento,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.formaPagamento,
                      onChanged: _servicoUpdateForm.setFormaPagamento,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'formaPagamento',
                      ),
                    ), // Forma de Pagamento
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
                    ), // Data Encerramento
                    
                    CustomTextFormField(
                      label: 'Valor Comissão',
                      hint: 'Valor Comissão...',
                      leftPadding: 4,
                      rightPadding: 4,
                      maxLength: 8,
                      hide: true,
                      type: TextInputType.numberWithOptions(decimal: true),
                      valueNotifier: _servicoUpdateForm.valorComissao,
                      onChanged: _servicoUpdateForm.setValorComissao,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        'valorComissao',
                      ),
                      inputFormatters: InputMasks.maskAlphanumericLetters,
                    ), // Valor Comissão
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
                    ), // Data Pagamento Comissão
                  ],
                );
              }
              return Column(
                children: [
                  Row(
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
                      ), // Equipamento
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
                      ), // Marca
                    ],
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
                    hide: true,
                  ), // Nome Técnico
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
                  ), // Filial
                  Row(
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
                      ), // Garantia
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
                      ), // Situação
                    ],
                  ),
                  Row(
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
                      ), // Horário
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
                          valueNotifier: _servicoUpdateForm.dataAtendimentoPrevisto,
                          onChanged: _servicoUpdateForm.setDataAtendimentoPrevisto,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'dataAtendimentoPrevisto',
                          ),
                        ),
                      ), // Data Atendimento Previsto
                    ],
                  ),
                  Row(
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
                          valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                          onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'dataAtendimentoEfetivo',
                          ),
                        ),
                      ), // Data Atendimento Efetivo
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
                          valueNotifier: _servicoUpdateForm.dataAtendimentoAbertura,
                          onChanged: _servicoUpdateForm.setDataAtendimentoAbertura,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'dataAtendimentoAbertura',
                          ),
                        ),
                      ), // Data Abertura -- Tirar
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          label: 'Valor Serviço',
                          hint: 'Valor Serviço...',
                          leftPadding: 4,
                          rightPadding: 4,
                          maxLength: 8,
                          hide: true,
                          type: TextInputType.numberWithOptions(decimal: true),
                          valueNotifier: _servicoUpdateForm.valor,
                          onChanged: _servicoUpdateForm.setValor,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'valor',
                          ),
                          inputFormatters: InputMasks.maskAlphanumericLetters,
                        ),
                      ), // Valor
                      Expanded(
                        child: CustomTextFormField(
                          label: 'Valor Peças',
                          hint: 'Valor Peças...',
                          leftPadding: 4,
                          rightPadding: 4,
                          maxLength: 8,
                          hide: true,
                          type: TextInputType.numberWithOptions(decimal: true),
                          valueNotifier: _servicoUpdateForm.valorPecas,
                          onChanged: _servicoUpdateForm.setValorPecas,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'valorPecas',
                          ),
                          inputFormatters: InputMasks.maskAlphanumericLetters,
                        ),
                      ), // Valor Peças
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdownFormField(
                          label: 'Forma de Pagamento',
                          dropdownValues: Constants.formasPagamento,
                          leftPadding: 4,
                          rightPadding: 4,
                          valueNotifier: _servicoUpdateForm.formaPagamento,
                          onChanged: _servicoUpdateForm.setFormaPagamento,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'formaPagamento',
                          ),
                        ),
                      ), // Forma de Pagamento
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
                          valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                          onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'dataAtendimentoEfetivo',
                          ),
                        ),
                      ), // Data Encerramento
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          label: 'Valor Comissão',
                          hint: 'Valor Comissão...',
                          leftPadding: 4,
                          rightPadding: 4,
                          maxLength: 8,
                          hide: true,
                          type: TextInputType.numberWithOptions(decimal: true),
                          valueNotifier: _servicoUpdateForm.valorComissao,
                          onChanged: _servicoUpdateForm.setValorComissao,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'valorComissao',
                          ),
                          inputFormatters: InputMasks.maskAlphanumericLetters,
                        ),
                      ), // Valor Comissão
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
                          valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                          onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'dataAtendimentoEfetivo',
                          ),
                        ),
                      ), // Data Pagamento Comissão
                    ],
                  ),
                ],
              );
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
            validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.descricao.name),
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
      appBar: AppBarForm(
        onPressed: _handleBackNavigation,
        title: "Voltar",
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
        buildWhen: (previousState, state) => (state is ServicoSearchOneSuccessState),
        builder: (context, state) {
          if (state is ServicoSearchOneSuccessState) {
            _populateFormWithState(state);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48.0),
                            child: const Text(
                              "Atualizar Serviço",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 800) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          CardBuilderForm(
                                            title: "Cliente",
                                            child: _buildClientForm()
                                          ),
                                          const SizedBox(height: 8),
                                          BuildFieldLabels(isClientAndService: false),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 4,
                                      child: CardBuilderForm(
                                        title: "Serviço",
                                        child: _buildServiceForm()
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  CardBuilderForm(
                                    title: "Cliente",
                                    child: _buildClientForm()
                                  ),
                                  const SizedBox(height: 16),
                                  CardBuilderForm(
                                    title: "Serviço",
                                    child: _buildServiceForm()
                                  ),
                                  const SizedBox(height: 8),
                                  BuildFieldLabels(isClientAndService: false),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 750),
                            child: BlocListener<ServicoBloc, ServicoState>(
                              listener: (context, state) {
                                if (state is ServicoUpdateSuccessState) {
                                  _handleBackNavigation();
                                }
                                else if (state is ServicoErrorState) {
                                  _handleError(state);
                                }
                              },
                              child: Column(
                                children: [
                                  ElevatedFormButton(
                                    text: "Ver Histórico de Atendimento",
                                    onPressed: () {},
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedFormButton(
                                    text: "Atualizar Serviço",
                                    onPressed: _updateServico,
                                  ),
                                ],
                              ),
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
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }
}
