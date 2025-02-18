import 'dart:async';

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
import 'package:serv_oeste/src/components/screen/client_selection_modal.dart';
import 'package:serv_oeste/src/components/screen/elevated_form_button.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
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
  Timer? _debounce;
  late final ServicoBloc _servicoBloc;
  late final TecnicoBloc _tecnicoBloc;
  late final ClienteBloc _clienteBloc;

  late List<String> _dropdownNomeTecnicos;
  late List<TecnicoResponse> _tecnicos;
  late TextEditingController _nomeTecnicoController;
  late TextEditingController _nomeClienteController;
  late TextEditingController _enderecoController;

  final ServicoForm _servicoUpdateForm = ServicoForm();
  final ClienteForm _clienteUpdateForm = ClienteForm();
  final ServicoValidator _servicoUpdateValidator = ServicoValidator(isUpdate: true);
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _servicoUpdateForm.setId(widget.id);
    _tecnicos = [];
    _dropdownNomeTecnicos = [];
    _nomeTecnicoController = TextEditingController();
    _nomeClienteController = TextEditingController();
    _enderecoController = TextEditingController();
    _servicoBloc = context.read<ServicoBloc>();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _clienteBloc = context.read<ClienteBloc>();
    _servicoBloc.add(ServicoSearchOneEvent(id: widget.id));
    _clienteBloc.add(ClienteSearchEvent());
  }

  void _onNameTechnicalChanged(String nome) {
    _servicoUpdateForm.setIdTecnico(null);
    if (_servicoUpdateForm.equipamento.value.isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 150), () => _fetchTechnicalNames(nome));
  }

  void _fetchTechnicalNames(String nome) {
    _servicoUpdateForm.setNomeTecnico(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownNomeTecnicos.isEmpty) return;
    _tecnicoBloc.add(TecnicoSearchEvent(nome: nome, equipamento: _servicoUpdateForm.equipamento.value));
  }

  void _getTechnicalId(String nome) {
    _servicoUpdateForm.setNomeTecnico(nome);
    for (TecnicoResponse tecnico in _tecnicos) {
      if ("${tecnico.nome} ${tecnico.sobrenome}" == _servicoUpdateForm.nomeTecnico.value) {
        _servicoUpdateForm.setIdTecnico(tecnico.id);
      }
    }
  }

  void _getSelectedClientById(String id) {
    int? convertedId = int.tryParse(id);

    if (convertedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ID inválido. Por favor, insira um número."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _clienteBloc.add(ClienteSearchOneEvent(id: convertedId));
  }

  void _setClientFieldsValues(Cliente cliente) {
    _clienteUpdateForm.setNome(cliente.nome ?? '');
    _clienteUpdateForm.setMunicipio(cliente.municipio ?? '');
    _clienteUpdateForm.setBairro(cliente.bairro ?? '');

    List<String> enderecoParts = cliente.endereco?.split(',') ?? [];

    _clienteUpdateForm.setRua(enderecoParts.isNotEmpty ? enderecoParts.first.trim() : '');
    _clienteUpdateForm.setNumero(enderecoParts.length > 1 ? enderecoParts[1].trim() : '');
    _clienteUpdateForm.setComplemento(enderecoParts.length > 2 ? enderecoParts.sublist(2).join(',').trim() : '');

    _servicoUpdateForm.setIdCliente(cliente.id);
    _servicoUpdateForm.setNomeCliente(cliente.nome ?? '');
  }

  void _updateServico() {
    if (!_isValidForm()) {
      return;
    }

    Servico servico = Servico.fromForm(_servicoUpdateForm);
    _servicoBloc.add(ServicoUpdateEvent(servico: servico));

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

  void _showClientSelectionModal(BuildContext context) {
    final currentState = _clienteBloc.state;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ClientSelectionModal(
            nomeController: _nomeClienteController,
            enderecoController: _enderecoController,
            onClientSelected: _getSelectedClientById,
          ),
        );
      },
    ).then((_) {
      _clienteBloc.add(RestoreClienteStateEvent(state: currentState));
    });
  }

  void _populateServicoFormWithState(ServicoSearchOneSuccessState stateServico) {
    _servicoUpdateForm.setIdCliente(stateServico.servico.idCliente);
    _servicoUpdateForm.setNomeCliente(stateServico.servico.nomeCliente);
    _servicoUpdateForm.setEquipamento(stateServico.servico.equipamento);
    _servicoUpdateForm.setMarca(stateServico.servico.marca);
    _servicoUpdateForm.setNomeTecnico(stateServico.servico.nomeTecnico);
    _servicoUpdateForm.setIdTecnico(stateServico.servico.idTecnico);
    _servicoUpdateForm.setFilial(stateServico.servico.filial);
    _servicoUpdateForm.setSituacao(stateServico.servico.situacao);
    _servicoUpdateForm.setHorario(stateServico.servico.horarioPrevisto);
    _servicoUpdateForm.setDataAtendimentoPrevistoDate(stateServico.servico.dataAtendimentoPrevisto);
    _servicoUpdateForm.setDataAtendimentoEfetivoDate(stateServico.servico.dataAtendimentoEfetivo);
    _servicoUpdateForm.setDataAtendimentoAberturaDate(stateServico.servico.dataAtendimentoAbertura);
    _servicoUpdateForm.setValor(stateServico.servico.valor.toString());
    _servicoUpdateForm.setValorPecas(stateServico.servico.valorPecas.toString());
    _servicoUpdateForm.setFormaPagamento(stateServico.servico.formaPagamento);
    _servicoUpdateForm.setDataFechamentoDate(stateServico.servico.dataFechamento);
    _servicoUpdateForm.setValorComissao(stateServico.servico.valorComissao.toString());
    _servicoUpdateForm.setDataPagamentoComissaoDate(stateServico.servico.dataPagamentoComissao);
    _servicoUpdateForm.setGarantiaBool(stateServico.servico.garantia);
    _servicoUpdateForm.setDataInicioGarantiaDate(stateServico.servico.dataInicioGarantia);
    _servicoUpdateForm.setDataFinalGarantiaDate(stateServico.servico.dataFimGarantia);
    _servicoUpdateForm.setHistorico(stateServico.servico.descricao);
  }

  Widget _buildClientForm() {
    return Form(
      key: _clienteFormKey,
      child: Column(
        children: [
          CustomTextFormField(
            label: 'Nome Cliente',
            hint: 'Nome Cliente...',
            type: TextInputType.text,
            leftPadding: 4,
            rightPadding: 4,
            maxLength: 255,
            hide: true,
            valueNotifier: _clienteUpdateForm.nome,
            onChanged: _clienteUpdateForm.setNome,
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
                      label: "Bairro",
                      hint: "Bairro...",
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
                      label: "Número",
                      hint: "Número...",
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
                          label: "Bairro",
                          hint: "Bairro...",
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
                          label: "Rua",
                          hint: "Rua...",
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
                          label: "Número",
                          hint: "Número...",
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
            label: "Complemento",
            hint: "Complemento...",
            type: TextInputType.text,
            maxLength: 255,
            hide: true,
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
                        ErrorCodeKey.equipamento.name,
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
                        ErrorCodeKey.marca.name,
                      ),
                      hide: true,
                    ), // Marca

                    BlocListener<TecnicoBloc, TecnicoState>(
                      listener: (context, state) {
                        if (state is TecnicoSearchSuccessState) {
                          _tecnicos = state.tecnicos;
                          List<String> nomes = state.tecnicos.take(5).map((tecnico) => "${tecnico.nome} ${tecnico.sobrenome}").toList();
                          if (_dropdownNomeTecnicos != nomes) {
                            setState(() {
                              _dropdownNomeTecnicos = nomes;
                            });
                          }
                        }
                      },
                      child: ValueListenableBuilder(
                        valueListenable: _servicoUpdateForm.equipamento,
                        builder: (context, value, child) {
                          bool isFieldEnabled = (value.isNotEmpty || _servicoUpdateForm.idCliente.value != null);
                          return Tooltip(
                            message: (isFieldEnabled) ? "" : "Selecione um equipamento para continuar",
                            textAlign: TextAlign.center,
                            child: CustomSearchDropDownFormField(
                              label: "Nome do Técnico*",
                              dropdownValues: _dropdownNomeTecnicos,
                              maxLength: 50,
                              hide: true,
                              leftPadding: 4,
                              rightPadding: 4,
                              controller: _nomeTecnicoController,
                              valueNotifier: _servicoUpdateForm.nomeTecnico,
                              validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.tecnico.name),
                              onChanged: _onNameTechnicalChanged,
                              onSelected: _getTechnicalId,
                              enabled: isFieldEnabled,
                            ),
                          );
                        },
                      ),
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
                        ErrorCodeKey.filial.name,
                      ),
                    ), // Filial

                    CustomDropdownFormField(
                      label: 'Horário*',
                      dropdownValues: Constants.dataAtendimento,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.horario,
                      onChanged: _servicoUpdateForm.setHorario,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.horario.name,
                      ),
                    ), // Horário

                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Atendimento Previsto*',
                      mask: InputMasks.data,
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataAtendimentoPrevisto,
                      onChanged: _servicoUpdateForm.setDataAtendimentoPrevisto,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.data.name,
                      ),
                    ), // Data Atendimento Previsto

                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Efetiva',
                      mask: InputMasks.data,
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                      onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        "ErrorCodeKey.data.name",
                      ),
                    ), // Data Atendimento Efetivo

                    CustomDropdownFormField(
                      label: 'Situação*',
                      dropdownValues: Constants.situationServiceList,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.situacao,
                      onChanged: _servicoUpdateForm.setSituacao,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.situacao.name,
                      ),
                    ), // Situação

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
                        ErrorCodeKey.valor.name,
                      ),
                      inputFormatters: InputMasks.alphanumericLetters,
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
                        ErrorCodeKey.valorPecas.name,
                      ),
                      inputFormatters: InputMasks.alphanumericLetters,
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
                      mask: InputMasks.data,
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataFechamento,
                      onChanged: _servicoUpdateForm.setDataFechamento,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.data.name,
                      ),
                    ), // Data Fechamento

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
                        ErrorCodeKey.valorComissao.name,
                      ),
                      enabled: false,
                      inputFormatters: InputMasks.alphanumericLetters,
                    ), // Valor Comissão

                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Pgto. comissão',
                      mask: InputMasks.data,
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataPagamentoComissao,
                      onChanged: _servicoUpdateForm.setDataPagamentoComissao,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.data.name,
                      ),
                    ), // Data Pagamento Comissão

                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Início da Garantia',
                      mask: InputMasks.data,
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataInicioGarantia,
                      onChanged: _servicoUpdateForm.setDataInicioGarantia,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.data.name,
                      ),
                    ), // Data Início Garantia

                    CustomDatePickerFormField(
                      hint: 'dd/mm/yyyy',
                      label: 'Data Final da Garantia',
                      mask: InputMasks.data,
                      maxLength: 10,
                      hide: true,
                      leftPadding: 4,
                      rightPadding: 4,
                      type: TextInputType.datetime,
                      valueNotifier: _servicoUpdateForm.dataFinalGarantia,
                      onChanged: _servicoUpdateForm.setDataFinalGarantia,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.data.name,
                      ),
                    ), // Data Final Garantia
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
                  BlocListener<TecnicoBloc, TecnicoState>(
                    listener: (context, state) {
                      if (state is TecnicoSearchSuccessState) {
                        _tecnicos = state.tecnicos;
                        List<String> nomes = state.tecnicos.take(5).map((tecnico) => "${tecnico.nome} ${tecnico.sobrenome}").toList();
                        if (_dropdownNomeTecnicos != nomes) {
                          setState(() {
                            _dropdownNomeTecnicos = nomes;
                          });
                        }
                      }
                    },
                    child: ValueListenableBuilder(
                      valueListenable: _servicoUpdateForm.equipamento,
                      builder: (context, value, child) {
                        bool isFieldEnabled = (value.isNotEmpty || _servicoUpdateForm.idCliente.value != null);
                        return Tooltip(
                          message: (isFieldEnabled) ? "" : "Selecione um equipamento para continuar",
                          textAlign: TextAlign.center,
                          child: CustomSearchDropDownFormField(
                            label: "Nome do Técnico*",
                            dropdownValues: _dropdownNomeTecnicos,
                            maxLength: 50,
                            hide: true,
                            leftPadding: 4,
                            rightPadding: 4,
                            controller: _nomeTecnicoController,
                            valueNotifier: _servicoUpdateForm.nomeTecnico,
                            validator: _servicoUpdateValidator.byField(_servicoUpdateForm, ErrorCodeKey.tecnico.name),
                            onChanged: _onNameTechnicalChanged,
                            onSelected: _getTechnicalId,
                            enabled: isFieldEnabled,
                          ),
                        );
                      },
                    ),
                  ), // Nome Técnico
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
                            ErrorCodeKey.horario.name,
                          ),
                        ),
                      ), // Horário
                      Expanded(
                        child: CustomDropdownFormField(
                          label: 'Filial*',
                          dropdownValues: Constants.filiais,
                          leftPadding: 4,
                          rightPadding: 4,
                          valueNotifier: _servicoUpdateForm.filial,
                          onChanged: _servicoUpdateForm.setFilial,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.filial.name,
                          ),
                        ), // Filial
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Efetiva',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataAtendimentoEfetivo,
                          onChanged: _servicoUpdateForm.setDataAtendimentoEfetivo,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.data.name,
                          ),
                        ),
                      ), // Data Atendimento Efetivo
                      Expanded(
                        child: CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Atendimento Previsto*',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataAtendimentoPrevisto,
                          onChanged: _servicoUpdateForm.setDataAtendimentoPrevisto,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.data.name,
                          ),
                        ), // Data Atendimento Previsto
                      ),
                    ],
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
                      ErrorCodeKey.situacao.name,
                    ),
                  ), // Situação
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
                            ErrorCodeKey.valor.name,
                          ),
                          inputFormatters: InputMasks.alphanumericLetters,
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
                            ErrorCodeKey.valorPecas.name,
                          ),
                          inputFormatters: InputMasks.alphanumericLetters,
                        ),
                      ), // Valor Peças
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
                            ErrorCodeKey.valorComissao.name,
                          ),
                          enabled: false,
                          inputFormatters: InputMasks.alphanumericLetters,
                        ),
                      ), // Valor Comissão
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
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Fechamento',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataFechamento,
                          onChanged: _servicoUpdateForm.setDataFechamento,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.data.name,
                          ),
                        ),
                      ), // Data Fechamento
                      Expanded(
                        child: CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Pgto. comissão',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataPagamentoComissao,
                          onChanged: _servicoUpdateForm.setDataPagamentoComissao,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.data.name,
                          ),
                        ),
                      ), // Data Pagamento Comissão
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Início da Garantia',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataInicioGarantia,
                          onChanged: _servicoUpdateForm.setDataInicioGarantia,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.data.name,
                          ),
                        ),
                      ), // Data Início Garantia
                      Expanded(
                        child: CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Final da Garantia',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataFinalGarantia,
                          onChanged: _servicoUpdateForm.setDataFinalGarantia,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.data.name,
                          ),
                        ),
                      ), // Data Final Garantia
                    ],
                  ),
                ],
              );
            },
          ),
          CustomTextFormField(
            hint: "Descrição/Observação...",
            label: "Descrição/Observação*",
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
        builder: (context, servicoState) {
          if (servicoState is ServicoSearchOneSuccessState) {
            _clienteBloc.add(ClienteSearchOneEvent(id: servicoState.servico.idCliente));
            _populateServicoFormWithState(servicoState);

            return BlocBuilder<ClienteBloc, ClienteState>(
              builder: (context, clienteState) {
                if (clienteState is ClienteSearchOneSuccessState) {
                  _setClientFieldsValues(clienteState.cliente);
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
                                    "Consultar/Atualizar Serviço",
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
                                                CardBuilderForm(title: "Cliente", child: _buildClientForm()),
                                                const SizedBox(height: 8),
                                                BuildFieldLabels(isClientAndService: false),
                                                const SizedBox(height: 28),
                                                ElevatedFormButton(
                                                  text: "Alterar Cliente",
                                                  onPressed: () => _showClientSelectionModal(context),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 4,
                                            child: CardBuilderForm(title: "Serviço", child: _buildServiceForm()),
                                          ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        CardBuilderForm(title: "Cliente", child: _buildClientForm()),
                                        const SizedBox(height: 12),
                                        ElevatedFormButton(
                                          text: "Alterar Cliente",
                                          onPressed: () => _showClientSelectionModal(context),
                                        ),
                                        const SizedBox(height: 12),
                                        CardBuilderForm(title: "Serviço", child: _buildServiceForm()),
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
                                      } else if (state is ServicoErrorState) {
                                        _handleError(state);
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        ElevatedFormButton(
                                          text: "Ver Histórico de Atendimento",
                                          onPressed: () {
                                            showAdaptiveDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  "Histórico",
                                                  textAlign: TextAlign.center,
                                                ),
                                                backgroundColor: const Color(0xFFF9F9FF),
                                                content: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: const Color(0xFFEAE6E5),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      _servicoUpdateForm.historico.value,
                                                      textAlign: TextAlign.center,
                                                    )),
                                                actions: [
                                                  ElevatedFormButton(
                                                    text: "Ok",
                                                    onPressed: () => Navigator.pop(context),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
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
            );
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nomeTecnicoController.dispose();
    _nomeClienteController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }
}
