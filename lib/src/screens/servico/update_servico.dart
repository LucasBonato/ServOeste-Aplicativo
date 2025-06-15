import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/date_picker_form_field.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/components/screen/cards/card_builder_form.dart';
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
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/pdfs/orcamento_pdf.dart';
import 'package:serv_oeste/src/pdfs/recibo_pdf.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/currency_input_formatter.dart';
import 'package:serv_oeste/src/shared/formatters.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class UpdateServico extends StatefulWidget {
  final int id;

  const UpdateServico({super.key, required this.id});

  @override
  State<UpdateServico> createState() => _UpdateServicoState();
}

class _UpdateServicoState extends State<UpdateServico> {
  Timer? _debounce;
  late String _currentSituation;
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
  final ServicoValidator _servicoUpdateValidator =
      ServicoValidator(isUpdate: true);
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();

  final ValueNotifier<bool> isNomeTecnicoEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isHorarioEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isDataAtendimentoPrevistoEnabled =
      ValueNotifier(false);
  final ValueNotifier<bool> isDataAtendimentoEfetivoEnabled =
      ValueNotifier(false);
  final ValueNotifier<bool> isValorServicoEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isValorPecasEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isFormaPagamentoEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isDataFechamentoEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isDataPagamentoComissaoEnabled =
      ValueNotifier(false);
  final ValueNotifier<bool> isDataInicioGarantiaEnabled = ValueNotifier(false);
  final ValueNotifier<bool> isDataFinalGarantiaEnabled = ValueNotifier(false);

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
    _debounce =
        Timer(Duration(milliseconds: 150), () => _fetchTechnicalNames(nome));
  }

  void _fetchTechnicalNames(String nome) {
    if (!mounted) return;

    _servicoUpdateForm.setNomeTecnico(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownNomeTecnicos.isEmpty) return;
    _tecnicoBloc.add(TecnicoSearchEvent(
        nome: nome, equipamento: _servicoUpdateForm.equipamento.value));
  }

  void _getTechnicalId(String nome) {
    _servicoUpdateForm.setNomeTecnico(nome);
    for (TecnicoResponse tecnico in _tecnicos) {
      if ("${tecnico.nome} ${tecnico.sobrenome}" ==
          _servicoUpdateForm.nomeTecnico.value) {
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

    _clienteUpdateForm
        .setRua(enderecoParts.isNotEmpty ? enderecoParts.first.trim() : '');
    _clienteUpdateForm
        .setNumero(enderecoParts.length > 1 ? enderecoParts[1].trim() : '');
    _clienteUpdateForm.setComplemento(enderecoParts.length > 2
        ? enderecoParts.sublist(2).join(',').trim()
        : '');

    _servicoUpdateForm.setIdCliente(cliente.id);
    _servicoUpdateForm.setNomeCliente(cliente.nome ?? '');
  }

  String _convertEnumStatusToString(String status) {
    final specialCases = {
      'NAO_RETIRA_3_MESES': 'Não retira há 3 meses',
      'AGUARDANDO_APROVACAO': 'Aguardando aprovação do cliente',
      'AGUARDANDO_ORCAMENTO': 'Aguardando orçamento',
      'ORCAMENTO_APROVADO': 'Orçamento aprovado',
      'NAO_APROVADO': 'Não aprovado pelo cliente',
    };

    if (specialCases.containsKey(status)) {
      return specialCases[status]!;
    }

    String convertedStatus =
        "${status[0]}${status.substring(1).replaceAll("_", " ").toLowerCase()}";
    return convertedStatus;
  }

  void _populateServicoFormWithState(
      ServicoSearchOneSuccessState stateServico) {
    _currentSituation =
        _convertEnumStatusToString(stateServico.servico.situacao);

    Logger().w(
        Formatters.formatToCurrency(stateServico.servico.valorComissao ?? 0.0));

    _servicoUpdateForm.setIdCliente(stateServico.servico.idCliente);
    _servicoUpdateForm.setNomeCliente(stateServico.servico.nomeCliente);
    _servicoUpdateForm.setEquipamento(stateServico.servico.equipamento);
    _servicoUpdateForm.setMarca(stateServico.servico.marca);
    _servicoUpdateForm.setNomeTecnico(stateServico.servico.nomeTecnico);
    _servicoUpdateForm.setIdTecnico(stateServico.servico.idTecnico);
    _servicoUpdateForm.setFilial(stateServico.servico.filial);
    _servicoUpdateForm.setSituacao(stateServico.servico.situacao);
    _servicoUpdateForm.setHorario(stateServico.servico.horarioPrevisto);
    _servicoUpdateForm.setDataAtendimentoPrevistoDate(
        stateServico.servico.dataAtendimentoPrevisto);
    _servicoUpdateForm.setDataAtendimentoEfetivoDate(
        stateServico.servico.dataAtendimentoEfetivo);
    _servicoUpdateForm.setDataAtendimentoAberturaDate(
        stateServico.servico.dataAtendimentoAbertura);
    _servicoUpdateForm.setValorServico(
        Formatters.formatToCurrency(stateServico.servico.valor ?? 0.0));
    _servicoUpdateForm.setValorPecas(
        Formatters.formatToCurrency(stateServico.servico.valorPecas ?? 0.0));
    _servicoUpdateForm.setValorComissao(
        Formatters.formatToCurrency(stateServico.servico.valorComissao ?? 0.0));
    _servicoUpdateForm.setFormaPagamento(stateServico.servico.formaPagamento);
    _servicoUpdateForm
        .setDataFechamentoDate(stateServico.servico.dataFechamento);
    _servicoUpdateForm.setDataPagamentoComissaoDate(
        stateServico.servico.dataPagamentoComissao);
    _servicoUpdateForm.setGarantiaBool(stateServico.servico.garantia);
    _servicoUpdateForm
        .setDataInicioGarantiaDate(stateServico.servico.dataInicioGarantia);
    _servicoUpdateForm
        .setDataFinalGarantiaDate(stateServico.servico.dataFimGarantia);
    _servicoUpdateForm.setHistorico(stateServico.servico.descricao);

    _updateEnabledFields();
  }

  void _updateEnabledFields() {
    bool isFieldDisabled(List<String> disabledSituations) {
      return disabledSituations.contains(_servicoUpdateForm.situacao.value);
    }

    final List<String> situacoesNomeTecnicoDisabled = [
      'Aguardando agendamento',
    ];

    final List<String> situacoesHorarioDisabled = [
      'Aguardando agendamento',
    ];

    final List<String> situacoesDataAtendimentoPrevistoDisabled = [
      'Aguardando agendamento',
    ];

    final List<String> situacoesDataAtendimentoEfetivoDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Cancelado',
    ];

    final List<String> situacoesValorServicoDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Cancelado',
      'Sem defeito',
      'Aguardando orçamento',
    ];

    final List<String> situacoesValorPecasDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Cancelado',
      'Sem defeito',
      'Aguardando orçamento',
    ];

    final List<String> situacoesFormaPagamentoDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Cancelado',
      'Sem defeito',
      'Aguardando orçamento',
      'Aguardando aprovação do cliente',
      'Não aprovado pelo cliente',
      'Compra',
    ];

    final List<String> situacoesDataFechamentoDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Aguardando orçamento',
      'Aguardando aprovação do cliente',
      'Orçamento aprovado',
      'Aguardando cliente retirar',
      'Cortesia',
      'Garantia',
    ];

    final List<String> situacoesDataPagamentoComissaoDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Cancelado',
      'Sem defeito',
      'Aguardando orçamento',
      'Aguardando aprovação do cliente',
      'Não aprovado pelo cliente',
      'Compra',
    ];

    final List<String> situacoesDataInicioGarantiaDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Cancelado',
      'Sem defeito',
      'Aguardando orçamento',
      'Aguardando aprovação do cliente',
      'Não aprovado pelo cliente',
      'Compra',
      'Orçamento aprovado',
      'Aguardando cliente retirar',
      'Não retira há 3 meses',
    ];

    final List<String> situacoesDataFinalGarantiaDisabled = [
      'Aguardando agendamento',
      'Aguardando atendimento',
      'Cancelado',
      'Sem defeito',
      'Aguardando orçamento',
      'Aguardando aprovação do cliente',
      'Não aprovado pelo cliente',
      'Compra',
      'Orçamento aprovado',
      'Aguardando cliente retirar',
      'Não retira há 3 meses',
    ];

    isNomeTecnicoEnabled.value = !isFieldDisabled(situacoesNomeTecnicoDisabled);

    isHorarioEnabled.value = !isFieldDisabled(situacoesHorarioDisabled);

    isDataAtendimentoPrevistoEnabled.value =
        !isFieldDisabled(situacoesDataAtendimentoPrevistoDisabled);

    isDataAtendimentoEfetivoEnabled.value =
        !isFieldDisabled(situacoesDataAtendimentoEfetivoDisabled);

    isValorServicoEnabled.value =
        !isFieldDisabled(situacoesValorServicoDisabled);

    isValorPecasEnabled.value = !isFieldDisabled(situacoesValorPecasDisabled);

    isFormaPagamentoEnabled.value =
        !isFieldDisabled(situacoesFormaPagamentoDisabled);

    isDataFechamentoEnabled.value =
        !isFieldDisabled(situacoesDataFechamentoDisabled);

    isDataPagamentoComissaoEnabled.value =
        !isFieldDisabled(situacoesDataPagamentoComissaoDisabled);

    isDataInicioGarantiaEnabled.value =
        !isFieldDisabled(situacoesDataInicioGarantiaDisabled);

    isDataFinalGarantiaEnabled.value =
        !isFieldDisabled(situacoesDataFinalGarantiaDisabled);
  }

  void _updateServico() {
    if (!_isValidForm()) {
      return;
    }

    Servico servico = Servico.fromForm(_servicoUpdateForm);
    _servicoBloc.add(ServicoUpdateEvent(servico: servico));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Serviço atualizado com sucesso! (Caso ele não esteja atualizado, recarregue a página)')),
    );
  }

  int _getServiceLevel(String situacao) {
    return switch (situacao) {
      'Aguardando agendamento' => 0,
      'Aguardando atendimento' => 1,
      'Cancelado' || 'Sem defeito' || 'Aguardando orçamento' => 2,
      'Aguardando aprovação do cliente' => 3,
      'Compra' || 'Não aprovado pelo cliente' || 'Orçamento aprovado' => 4,
      'Aguardando cliente retirar' => 5,
      'Não retira há 3 meses' => 6,
      'Resolvido' || 'Cortesia' || 'Garantia' => 7,
      _ => -1,
    };
  }

  void _handleSituationChange(String value) {
    if (!mounted) return;

    final String previousValue = _currentSituation;
    final int currentLevel = _getServiceLevel(previousValue);
    final int newLevel = _getServiceLevel(value);

    Logger().w(
        "Mudando de $previousValue (Nível: $currentLevel) para $value (Nível: $newLevel)");

    if (currentLevel > newLevel) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          if (!mounted) return;

          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 28),
                    SizedBox(width: 8),
                    Text("Aviso!",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Text(
                  "Esta alteração irá retroceder a situação do serviço.\nDeseja realizar realmente a alteração?",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _servicoUpdateForm.situacao.value = previousValue;
                      _servicoUpdateForm.setSituacao(previousValue);
                    },
                    child: Text("Cancelar",
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 16)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _updateServiceSituation(value);
                    },
                    child: Text("Confirmar",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
              );
            },
          );
          if (confirm == true && mounted) {
            _updateServiceSituation(value);
          }
        },
      );
    } else {
      _updateServiceSituation(value);
    }
  }

  void _updateServiceSituation(String value) {
    Logger().w(
        "Atualizando situação para: $value (Nível: ${_getServiceLevel(value)})");
    if (_servicoUpdateForm.situacao.value == value) return;

    _servicoUpdateForm.situacao.value = value;
    _servicoUpdateForm.setSituacao(value);
    _updateEnabledFields();
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    _servicoFormKey.currentState?.validate();
    final ValidationResult response =
        _servicoUpdateValidator.validate(_servicoUpdateForm);
    return response.isValid;
  }

  void _handleBackNavigation() {
    _servicoBloc.add(ServicoSearchMenuEvent());
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
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.municipio.name),
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
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.bairro.name),
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
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.rua.name),
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
                      validator: _servicoUpdateValidator.byField(
                          _servicoUpdateForm, ErrorCodeKey.numero.name),
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
                          validator: _servicoUpdateValidator.byField(
                              _servicoUpdateForm, ErrorCodeKey.municipio.name),
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
                          validator: _servicoUpdateValidator.byField(
                              _servicoUpdateForm, ErrorCodeKey.bairro.name),
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
                          label: "Número",
                          hint: "Número...",
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
                          List<String> nomes = state.tecnicos
                              .take(5)
                              .map((tecnico) =>
                                  "${tecnico.nome} ${tecnico.sobrenome}")
                              .toList();
                          if (_dropdownNomeTecnicos != nomes) {
                            if (mounted) {
                              setState(() {
                                _dropdownNomeTecnicos = nomes;
                              });
                            }
                          }
                        }
                      },
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isNomeTecnicoEnabled,
                        builder: (context, isEnabled, child) {
                          return ValueListenableBuilder(
                            valueListenable: _servicoUpdateForm.equipamento,
                            builder: (context, value, child) {
                              bool isFieldEnabled = isEnabled &&
                                  (value.isNotEmpty ||
                                      _servicoUpdateForm.idCliente.value !=
                                          null);
                              return Tooltip(
                                message: (isFieldEnabled)
                                    ? ""
                                    : "Selecione um equipamento para continuar",
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
                                  validator: ([value]) {
                                    if (isFieldEnabled &&
                                        (value == null || value.isEmpty)) {
                                      return "Nome do técnico é obrigatório";
                                    }
                                    return null;
                                  },
                                  onChanged: _onNameTechnicalChanged,
                                  onSelected: _getTechnicalId,
                                  enabled: isFieldEnabled,
                                ),
                              );
                            },
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
                      enabled: false,
                    ), // Filial

                    ValueListenableBuilder<bool>(
                      valueListenable: isHorarioEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDropdownFormField(
                          label: 'Horário*',
                          dropdownValues: Constants.dataAtendimento,
                          leftPadding: 4,
                          rightPadding: 4,
                          valueNotifier: _servicoUpdateForm.horario,
                          onChanged: (String? novoValor) {
                            _servicoUpdateForm.setHorario(
                                novoValor == "Selecione um horário"
                                    ? null
                                    : novoValor);
                          },
                          validator: ([value]) {
                            if (_servicoUpdateForm.situacao.value ==
                                "Cancelado") {
                              return null;
                            }
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Horário é obrigatório";
                            }
                            return null;
                          },
                          enabled: isEnabled,
                        );
                      },
                    ), // Horário

                    ValueListenableBuilder<bool>(
                      valueListenable: isDataAtendimentoPrevistoEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Atendimento Previsto*',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier:
                              _servicoUpdateForm.dataAtendimentoPrevisto,
                          onChanged:
                              _servicoUpdateForm.setDataAtendimentoPrevisto,
                          validator: ([value]) {
                            if (_servicoUpdateForm.situacao.value ==
                                "Cancelado") {
                              return null;
                            }
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Data de atendimento previsto é obrigatória";
                            }
                            return null;
                          },
                          enabled: isEnabled,
                        );
                      },
                    ), // Data Atendimento Previsto

                    ValueListenableBuilder<bool>(
                      valueListenable: isDataAtendimentoEfetivoEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Efetiva*',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier:
                              _servicoUpdateForm.dataAtendimentoEfetivo,
                          onChanged:
                              _servicoUpdateForm.setDataAtendimentoEfetivo,
                          validator: ([value]) {
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Data efetiva é obrigatória";
                            }
                            return null;
                          },
                          enabled: isEnabled,
                        );
                      },
                    ), // Data Atendimento Efetivo

                    CustomDropdownFormField(
                      label: 'Situação*',
                      dropdownValues: Constants.situationServiceList,
                      leftPadding: 4,
                      rightPadding: 4,
                      valueNotifier: _servicoUpdateForm.situacao,
                      onChanged: (String? newValue) {
                        if (newValue != null &&
                            newValue != _servicoUpdateForm.situacao.value) {
                          _handleSituationChange(newValue);
                        }
                      },
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.situacao.name,
                      ),
                    ), // Situação

                    ValueListenableBuilder<bool>(
                      valueListenable: isValorServicoEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomTextFormField(
                          label: 'Valor Serviço*',
                          hint: '9.999,99',
                          leftPadding: 4,
                          rightPadding: 4,
                          maxLength: 13,
                          hide: true,
                          type: TextInputType.numberWithOptions(decimal: true),
                          valueNotifier: _servicoUpdateForm.valor,
                          onChanged: _servicoUpdateForm.setValorServico,
                          validator: ([value]) {
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Valor do serviço é obrigatório";
                            }
                            return null;
                          },
                          inputFormatters: [
                            CurrencyInputFormatter(),
                          ],
                          enabled: isEnabled,
                        );
                      },
                    ), // Valor Serviço

                    ValueListenableBuilder<bool>(
                      valueListenable: isValorPecasEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomTextFormField(
                          label: 'Valor Peças*',
                          hint: '9.999,99',
                          leftPadding: 4,
                          rightPadding: 4,
                          maxLength: 13,
                          hide: true,
                          type: TextInputType.numberWithOptions(decimal: true),
                          valueNotifier: _servicoUpdateForm.valorPecas,
                          onChanged: _servicoUpdateForm.setValorPecas,
                          validator: ([value]) {
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Valor das peças é obrigatório";
                            }
                            return null;
                          },
                          inputFormatters: [
                            CurrencyInputFormatter(),
                          ],
                          enabled: isEnabled,
                        );
                      },
                    ), // Valor Peças

                    ValueListenableBuilder<bool>(
                      valueListenable: isFormaPagamentoEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDropdownFormField(
                          label: 'Forma de Pagamento*',
                          dropdownValues: Constants.formasPagamento,
                          leftPadding: 4,
                          rightPadding: 4,
                          valueNotifier: _servicoUpdateForm.formaPagamento,
                          onChanged: _servicoUpdateForm.setFormaPagamento,
                          validator: ([value]) {
                            final situacoesOpcionais = [
                              "Orçamento aprovado",
                              "Aguardando cliente retirar",
                              "Não retira há 3 meses",
                            ];

                            if (situacoesOpcionais
                                .contains(_servicoUpdateForm.situacao.value)) {
                              return null;
                            }
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Forma de pagamento é obrigatória";
                            }
                            return null;
                          },
                          enabled: isEnabled,
                        );
                      },
                    ), // Forma de Pagamento

                    ValueListenableBuilder<bool>(
                      valueListenable: isDataFechamentoEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Encerramento*',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataFechamento,
                          onChanged: _servicoUpdateForm.setDataFechamento,
                          validator: ([value]) {
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Data de encerramento é obrigatória";
                            }
                            return null;
                          },
                          enabled: isEnabled,
                        );
                      },
                    ), // Data Encerramento

                    CustomTextFormField(
                      label: 'Valor Comissão',
                      leftPadding: 4,
                      rightPadding: 4,
                      maxLength: 13,
                      hide: true,
                      type: TextInputType.numberWithOptions(decimal: true),
                      valueNotifier: _servicoUpdateForm.valorComissao,
                      onChanged: _servicoUpdateForm.setValorComissao,
                      validator: _servicoUpdateValidator.byField(
                        _servicoUpdateForm,
                        ErrorCodeKey.valorComissao.name,
                      ),
                      inputFormatters: [
                        CurrencyInputFormatter(),
                      ],
                      enabled: false,
                    ), // Valor Comissão

                    ValueListenableBuilder<bool>(
                      valueListenable: isDataPagamentoComissaoEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Pgto. comissão',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier:
                              _servicoUpdateForm.dataPagamentoComissao,
                          onChanged:
                              _servicoUpdateForm.setDataPagamentoComissao,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            'ErrorCodeKey.data.name',
                          ),
                          enabled: isEnabled,
                        );
                      },
                    ), // Data Pagamento Comissão

                    ValueListenableBuilder<bool>(
                      valueListenable: isDataInicioGarantiaEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Início da Garantia*',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataInicioGarantia,
                          onChanged: _servicoUpdateForm.setDataInicioGarantia,
                          validator: ([value]) {
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Data início da garantia é obrigatória";
                            }
                            return null;
                          },
                          enabled: isEnabled,
                        );
                      },
                    ), // Data Início Garantia

                    ValueListenableBuilder<bool>(
                      valueListenable: isDataFinalGarantiaEnabled,
                      builder: (context, isEnabled, child) {
                        return CustomDatePickerFormField(
                          hint: 'dd/mm/yyyy',
                          label: 'Data Final da Garantia*',
                          mask: InputMasks.data,
                          maxLength: 10,
                          hide: true,
                          leftPadding: 4,
                          rightPadding: 4,
                          type: TextInputType.datetime,
                          valueNotifier: _servicoUpdateForm.dataFinalGarantia,
                          onChanged: _servicoUpdateForm.setDataFinalGarantia,
                          validator: ([value]) {
                            if (isEnabled && (value == null || value.isEmpty)) {
                              return "Data final da garantia é obrigatório";
                            }
                            return null;
                          },
                          enabled: isEnabled,
                        );
                      },
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
                        List<String> nomes = state.tecnicos
                            .take(5)
                            .map((tecnico) =>
                                "${tecnico.nome} ${tecnico.sobrenome}")
                            .toList();
                        if (_dropdownNomeTecnicos != nomes) {
                          if (mounted) {
                            setState(() {
                              _dropdownNomeTecnicos = nomes;
                            });
                          }
                        }
                      }
                    },
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isNomeTecnicoEnabled,
                      builder: (context, isEnabled, child) {
                        return ValueListenableBuilder(
                          valueListenable: _servicoUpdateForm.equipamento,
                          builder: (context, value, child) {
                            bool isFieldEnabled = isEnabled &&
                                (value.isNotEmpty ||
                                    _servicoUpdateForm.idCliente.value != null);
                            return Tooltip(
                              message: (isFieldEnabled)
                                  ? ""
                                  : "Selecione um equipamento para continuar",
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
                                validator: ([value]) {
                                  if (isFieldEnabled &&
                                      (value == null || value.isEmpty)) {
                                    return "Nome do técnico é obrigatório";
                                  }
                                  return null;
                                },
                                onChanged: _onNameTechnicalChanged,
                                onSelected: _getTechnicalId,
                                enabled: isFieldEnabled,
                              ),
                            );
                          },
                        );
                      },
                    ), // Nome Técnico
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isHorarioEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDropdownFormField(
                              label: 'Horário*',
                              dropdownValues: Constants.dataAtendimento,
                              leftPadding: 4,
                              rightPadding: 4,
                              valueNotifier: _servicoUpdateForm.horario,
                              onChanged: (String? novoValor) {
                                _servicoUpdateForm.setHorario(
                                    novoValor == "Selecione um horário"
                                        ? null
                                        : novoValor);
                              },
                              validator: ([value]) {
                                if (_servicoUpdateForm.situacao.value ==
                                    "Cancelado") {
                                  return null;
                                }
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Horário é obrigatório";
                                }
                                return null;
                              },
                              enabled: isEnabled,
                            );
                          },
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
                          enabled: false,
                        ), // Filial
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isDataAtendimentoPrevistoEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDatePickerFormField(
                              hint: 'dd/mm/yyyy',
                              label: 'Data Atendimento Previsto*',
                              mask: InputMasks.data,
                              maxLength: 10,
                              hide: true,
                              leftPadding: 4,
                              rightPadding: 4,
                              type: TextInputType.datetime,
                              valueNotifier:
                                  _servicoUpdateForm.dataAtendimentoPrevisto,
                              onChanged:
                                  _servicoUpdateForm.setDataAtendimentoPrevisto,
                              validator: ([value]) {
                                if (_servicoUpdateForm.situacao.value ==
                                    "Cancelado") {
                                  return null;
                                }
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Data de atendimento previsto é obrigatória";
                                }
                                return null;
                              },
                              enabled: isEnabled,
                            );
                          },
                        ), // Data Atendimento Previsto
                      ),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isDataAtendimentoEfetivoEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDatePickerFormField(
                              hint: 'dd/mm/yyyy',
                              label: 'Data Efetiva*',
                              mask: InputMasks.data,
                              maxLength: 10,
                              hide: true,
                              leftPadding: 4,
                              rightPadding: 4,
                              type: TextInputType.datetime,
                              valueNotifier:
                                  _servicoUpdateForm.dataAtendimentoEfetivo,
                              onChanged:
                                  _servicoUpdateForm.setDataAtendimentoEfetivo,
                              validator: ([value]) {
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Data efetiva é obrigatória";
                                }
                                return null;
                              },
                              enabled: isEnabled,
                            );
                          },
                        ), // Data Atendimento Efetivo
                      ),
                    ],
                  ),
                  CustomDropdownFormField(
                    label: 'Situação*',
                    dropdownValues: Constants.situationServiceList,
                    leftPadding: 4,
                    rightPadding: 4,
                    valueNotifier: _servicoUpdateForm.situacao,
                    onChanged: (String? newValue) {
                      if (newValue != null &&
                          newValue != _servicoUpdateForm.situacao.value) {
                        _handleSituationChange(newValue);
                      }
                    },
                    validator: _servicoUpdateValidator.byField(
                      _servicoUpdateForm,
                      ErrorCodeKey.situacao.name,
                    ),
                  ), // Situação
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isValorServicoEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomTextFormField(
                              label: 'Valor Serviço*',
                              hint: '9.999,99',
                              leftPadding: 4,
                              rightPadding: 4,
                              maxLength: 13,
                              hide: true,
                              type: TextInputType.numberWithOptions(
                                  decimal: true),
                              valueNotifier: _servicoUpdateForm.valor,
                              onChanged: (newValue) {
                                String sanitizedValue = newValue?.replaceAll(
                                        RegExp(r'[^\d.]'), '') ??
                                    '0';

                                double valor =
                                    double.tryParse(sanitizedValue) ?? 0.0;

                                _servicoUpdateForm
                                    .setValorServico(valor.toString());
                              },
                              validator: ([value]) {
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Valor do serviço é obrigatório";
                                }
                                return null;
                              },
                              inputFormatters: [
                                CurrencyInputFormatter(),
                              ],
                              enabled: isEnabled,
                              initialValue:
                                  _servicoUpdateForm.valor.value.toString(),
                            );
                          },
                        ),
                      ), // Valor Serviço
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isValorPecasEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomTextFormField(
                              label: 'Valor Peças*',
                              hint: '9.999,99',
                              leftPadding: 4,
                              rightPadding: 4,
                              maxLength: 13,
                              hide: true,
                              type: TextInputType.numberWithOptions(
                                  decimal: true),
                              valueNotifier: _servicoUpdateForm.valorPecas,
                              onChanged: _servicoUpdateForm.setValorPecas,
                              validator: ([value]) {
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Valor das peças é obrigatório";
                                }
                                return null;
                              },
                              inputFormatters: [
                                CurrencyInputFormatter(),
                              ],
                              enabled: isEnabled,
                            );
                          },
                        ),
                      ), // Valor Peças
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          label: 'Valor Comissão',
                          leftPadding: 4,
                          rightPadding: 4,
                          maxLength: 13,
                          hide: true,
                          type: TextInputType.numberWithOptions(decimal: true),
                          valueNotifier: _servicoUpdateForm.valorComissao,
                          onChanged: _servicoUpdateForm.setValorComissao,
                          validator: _servicoUpdateValidator.byField(
                            _servicoUpdateForm,
                            ErrorCodeKey.valorComissao.name,
                          ),
                          enabled: false,
                          inputFormatters: [
                            CurrencyInputFormatter(),
                          ],
                        ),
                      ), // Valor Comissão
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isFormaPagamentoEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDropdownFormField(
                              label: 'Forma de Pagamento*',
                              dropdownValues: Constants.formasPagamento,
                              leftPadding: 4,
                              rightPadding: 4,
                              valueNotifier: _servicoUpdateForm.formaPagamento,
                              onChanged: _servicoUpdateForm.setFormaPagamento,
                              validator: ([value]) {
                                final situacoesOpcionais = [
                                  "Orçamento aprovado",
                                  "Aguardando cliente retirar",
                                  "Não retira há 3 meses",
                                ];

                                if (situacoesOpcionais.contains(
                                    _servicoUpdateForm.situacao.value)) {
                                  return null;
                                }
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Forma de pagamento é obrigatória";
                                }
                                return null;
                              },
                              enabled: isEnabled,
                            );
                          },
                        ),
                      ), // Forma de Pagamento
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isDataFechamentoEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDatePickerFormField(
                              hint: 'dd/mm/yyyy',
                              label: 'Data Encerramento*',
                              mask: InputMasks.data,
                              maxLength: 10,
                              hide: true,
                              leftPadding: 4,
                              rightPadding: 4,
                              type: TextInputType.datetime,
                              valueNotifier: _servicoUpdateForm.dataFechamento,
                              onChanged: _servicoUpdateForm.setDataFechamento,
                              validator: ([value]) {
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Data de encerramento é obrigatória";
                                }
                                return null;
                              },
                              enabled: isEnabled,
                            );
                          },
                        ), // Data Encerramento
                      ),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isDataPagamentoComissaoEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDatePickerFormField(
                              hint: 'dd/mm/yyyy',
                              label: 'Data Pgto. comissão',
                              mask: InputMasks.data,
                              maxLength: 10,
                              hide: true,
                              leftPadding: 4,
                              rightPadding: 4,
                              type: TextInputType.datetime,
                              valueNotifier:
                                  _servicoUpdateForm.dataPagamentoComissao,
                              onChanged:
                                  _servicoUpdateForm.setDataPagamentoComissao,
                              validator: _servicoUpdateValidator.byField(
                                _servicoUpdateForm,
                                'ErrorCodeKey.data.name',
                              ),
                              enabled: isEnabled,
                            );
                          },
                        ), // Data Pagamento Comissão
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isDataInicioGarantiaEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDatePickerFormField(
                              hint: 'dd/mm/yyyy',
                              label: 'Data Início da Garantia*',
                              mask: InputMasks.data,
                              maxLength: 10,
                              hide: true,
                              leftPadding: 4,
                              rightPadding: 4,
                              type: TextInputType.datetime,
                              valueNotifier:
                                  _servicoUpdateForm.dataInicioGarantia,
                              onChanged:
                                  _servicoUpdateForm.setDataInicioGarantia,
                              validator: ([value]) {
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Data início da garantia é obrigatória";
                                }
                                return null;
                              },
                              enabled: isEnabled,
                            );
                          },
                        ), // Data Início Garantia
                      ),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isDataFinalGarantiaEnabled,
                          builder: (context, isEnabled, child) {
                            return CustomDatePickerFormField(
                              hint: 'dd/mm/yyyy',
                              label: 'Data Final da Garantia*',
                              mask: InputMasks.data,
                              maxLength: 10,
                              hide: true,
                              leftPadding: 4,
                              rightPadding: 4,
                              type: TextInputType.datetime,
                              valueNotifier:
                                  _servicoUpdateForm.dataFinalGarantia,
                              onChanged:
                                  _servicoUpdateForm.setDataFinalGarantia,
                              validator: ([value]) {
                                if (isEnabled &&
                                    (value == null || value.isEmpty)) {
                                  return "Data final da garantia é obrigatória";
                                }
                                return null;
                              },
                              enabled: isEnabled,
                            );
                          },
                        ), // Data Final Garantia
                      ),
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
      appBar: AppBarForm(
        onPressed: _handleBackNavigation,
        title: "Voltar",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
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
              onSelected: (String value) async {
                final servicoState = context.read<ServicoBloc>().state;
                final clienteState = context.read<ClienteBloc>().state;

                if (value == 'gerarOrcamento' &&
                    servicoState is ServicoSearchOneSuccessState &&
                    clienteState is ClienteSearchOneSuccessState) {
                  await generateOrcamentoPDF(
                    servico: servicoState.servico,
                    cliente: clienteState.cliente,
                    context: context,
                  );
                } else if (value == 'gerarRecibo' &&
                    servicoState is ServicoSearchOneSuccessState &&
                    clienteState is ClienteSearchOneSuccessState) {
                  await generateReciboPDF(
                    servico: servicoState.servico,
                    cliente: clienteState.cliente,
                    context: context,
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<ServicoBloc, ServicoState>(
        buildWhen: (previousState, state) =>
            (state is ServicoSearchOneSuccessState),
        builder: (context, servicoState) {
          if (servicoState is ServicoSearchOneSuccessState) {
            _clienteBloc
                .add(ClienteSearchOneEvent(id: servicoState.servico.idCliente));
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
                          behavior: ScrollBehavior()
                              .copyWith(overscroll: false, scrollbars: false),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 48.0),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              children: [
                                                CardBuilderForm(
                                                    title: "Cliente",
                                                    child: _buildClientForm()),
                                                const SizedBox(height: 8),
                                                BuildFieldLabels(
                                                    isClientAndService: false),
                                                const SizedBox(height: 28),
                                                ElevatedFormButton(
                                                  text: "Alterar Cliente",
                                                  onPressed: () =>
                                                      _showClientSelectionModal(
                                                          context),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 4,
                                            child: CardBuilderForm(
                                                title: "Serviço",
                                                child: _buildServiceForm()),
                                          ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        CardBuilderForm(
                                            title: "Cliente",
                                            child: _buildClientForm()),
                                        const SizedBox(height: 12),
                                        ElevatedFormButton(
                                          text: "Alterar Cliente",
                                          onPressed: () =>
                                              _showClientSelectionModal(
                                                  context),
                                        ),
                                        const SizedBox(height: 12),
                                        CardBuilderForm(
                                            title: "Serviço",
                                            child: _buildServiceForm()),
                                        const SizedBox(height: 8),
                                        BuildFieldLabels(
                                            isClientAndService: false),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 750),
                                  child:
                                      BlocListener<ServicoBloc, ServicoState>(
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
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    maxHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                  ),
                                                  child: AlertDialog(
                                                    title: const Text(
                                                      "Histórico do serviço",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFFF9F9FF),
                                                    content: SizedBox(
                                                      width: double.maxFinite,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            border: Border.all(
                                                              color: const Color(
                                                                  0xFFEAE6E5),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children:
                                                                _servicoUpdateForm
                                                                    .historico
                                                                    .value
                                                                    .split('\n')
                                                                    .expand(
                                                                        (texto) =>
                                                                            [
                                                                              Text(
                                                                                texto,
                                                                                textAlign: TextAlign.left,
                                                                              ),
                                                                              const Divider(
                                                                                color: Colors.black,
                                                                                thickness: 1,
                                                                                height: 10,
                                                                              ),
                                                                            ])
                                                                    .toList()
                                                                  ..removeLast(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      ElevatedFormButton(
                                                        text: "Ok",
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
