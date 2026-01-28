import 'package:flutter/material.dart';
import 'package:serv_oeste/core/constants/constants.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/formFields/tecnico/tecnico_search_field.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/servico_validator.dart';
import 'package:serv_oeste/src/screens/base_entity_form.dart';
import 'package:serv_oeste/src/utils/extensions/string_extensions.dart';
import 'package:serv_oeste/src/utils/formatters/input_masks.dart';

class ServicoFormWidget extends StatefulWidget {
  final String submitText;
  final String successMessage;
  final bool isUpdate;
  final bool isClientAndService;
  final ServicoBloc bloc;
  final TecnicoBloc tecnicoBloc;
  final ServicoValidator? validator;
  final GlobalKey<FormState>? formKey;
  final void Function() onSubmit;
  final ServicoForm form;
  final TextEditingController nameTecnicoController;
  final bool isForListScreen;

  const ServicoFormWidget({
    super.key,
    this.isUpdate = false,
    this.isClientAndService = false,
    required this.nameTecnicoController,
    required this.tecnicoBloc,
    required this.onSubmit,
    required this.submitText,
    required this.successMessage,
    required this.bloc,
    required this.form,
    this.validator,
    this.formKey,
    this.isForListScreen = false,
  });

  @override
  State<ServicoFormWidget> createState() => _ServicoFormWidgetState();
}

class _ServicoFormWidgetState extends State<ServicoFormWidget> {
  late GlobalKey<FormState> formKey;
  late ServicoValidator validator;
  late TextEditingController nameTecnicoController;
  late Map<String, List<String>> disabledSituationsByField;

  final ValueNotifier<String> _situationNotifier = ValueNotifier('');
  late bool enabled;

  @override
  void initState() {
    super.initState();

    formKey = widget.formKey ?? GlobalKey<FormState>();

    validator = widget.validator ??
        ServicoValidator(
          isUpdate: widget.isUpdate,
          isFieldEnabled: isFieldEnabled,
        );

    nameTecnicoController = widget.nameTecnicoController;
    disabledSituationsByField = {
      "nomeTecnico": ['Aguardando agendamento'],
      "horario": ['Aguardando agendamento'],
      "dataAtendimentoPrevisto": ['Aguardando agendamento'],
      "dataAtendimentoEfetivo": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
      ],
      "valorServico": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
      ],
      "valorPecas": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
      ],
      "formaPagamento": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
        'Aguardando aprovação do cliente',
        'Não aprovado pelo cliente',
        'Compra',
      ],
      "dataFechamento": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Aguardando orçamento',
        'Aguardando aprovação do cliente',
        'Orçamento aprovado',
        'Aguardando cliente retirar',
        'Cortesia',
        'Garantia',
      ],
      "dataPagamentoComissao": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
        'Aguardando aprovação do cliente',
        'Não aprovado pelo cliente',
        'Compra',
      ],
      "dataInicioGarantia": [
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
      ],
      "dataFinalGarantia": [
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
      ],
    };

    enabled = isInputEnabled();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _situationNotifier.value = widget.form.situacao.value;
    });
  }

  bool isInputEnabled() {
    if (widget.isUpdate) return true;
    return (widget.isClientAndService || widget.form.idCliente.value != null);
  }

  bool isFieldEnabled(String fieldName) {
    if (!widget.isUpdate) return enabled;

    final currentSituation = _situationNotifier.value;
    final disabledSituations = disabledSituationsByField[fieldName];

    if (disabledSituations == null) return true;

    final isEnabled = !disabledSituations.contains(currentSituation);

    return isEnabled;
  }

  int getServiceLevel(String situacao) {
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

  void updateServiceSituation(String value) {
    widget.form.situacao.value = value;
    widget.form.setSituacao(value);
    _situationNotifier.value = value;
  }

  void handleSituationChange(String value) {
    final String previousValue = widget.form.situacao.value.convertEnumStatusToString();
    final int currentLevel = getServiceLevel(previousValue);
    final int newLevel = getServiceLevel(value);

    if (currentLevel > newLevel) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 8),
                  Text("Aviso!", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.form.situacao.value = previousValue;
                    widget.form.setSituacao(previousValue);
                  },
                  child: Text("Cancelar", style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    updateServiceSituation(value);
                  },
                  child: Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            );
          },
        );
        if (confirm == true) {
          updateServiceSituation(value);
        }
      });
    } else {
      updateServiceSituation(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    enabled = isInputEnabled();

    return ValueListenableBuilder<String>(
      valueListenable: _situationNotifier,
      builder: (context, situation, child) {
        return BaseEntityForm<ServicoBloc, ServicoState>(
          bloc: widget.bloc,
          formKey: formKey,
          submitText: widget.submitText,
          isLoading: (state) => state is ServicoLoadingState,
          isSuccess: (state) => widget.isUpdate ? state is ServicoUpdateSuccessState : state is ServicoRegisterSuccessState,
          getSuccessMessage: (state) {
            return widget.successMessage;
          },
          isError: (state) => state is ServicoErrorState,
          onError: (state) {
            if (state is ServicoErrorState) {
              validator.applyBackendError(state.error);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                formKey.currentState?.validate();
              });
            }
          },
          shouldBuildButton: false,
          onSubmit: () async {
            validator.cleanExternalErrors();
            formKey.currentState?.validate();
            final result = validator.validate(widget.form);

            if (!result.isValid) return;
            widget.onSubmit();
          },
          buildFields: () {
            return [
              DropdownSearchInputField(
                hint: "Equipamento*",
                validator: validator.byField(widget.form, ErrorCodeKey.equipamento.name),
                valueNotifier: widget.form.equipamento,
                dropdownValues: Constants.equipamentos,
                onChanged: widget.form.setEquipamento,
                enabled: isFieldEnabled("equipamento"),
                shouldExpand: widget.isUpdate,
              ),
              DropdownSearchInputField(
                hint: "Marca*",
                validator: validator.byField(widget.form, ErrorCodeKey.marca.name),
                valueNotifier: widget.form.marca,
                dropdownValues: Constants.marcas,
                onChanged: widget.form.setMarca,
                enabled: isFieldEnabled("marca"),
                shouldExpand: widget.isUpdate,
              ),
              TecnicoSearchField(
                label: "Nome do Técnico*",
                tooltipMessage: "Selecione um equipamento para continuar",
                tecnicoBloc: widget.tecnicoBloc,
                validator: validator.byField(widget.form, ErrorCodeKey.tecnico.name),
                controller: nameTecnicoController,
                onChanged: widget.form.setNomeTecnico,
                onSearchStart: () => widget.form.setIdTecnico,
                listenTo: [widget.form.equipamento, widget.form.idCliente],
                enabledCalculator: () {
                  bool isEquipamentoNotEmpty = widget.form.equipamento.value.isNotEmpty;
                  bool hasCliente = widget.form.idCliente.value != null;

                  if (widget.isUpdate) {
                    return isFieldEnabled("nomeTecnico") && (isEquipamentoNotEmpty || hasCliente);
                  }

                  return (widget.isClientAndService)
                      ? (isEquipamentoNotEmpty || (!widget.isClientAndService || hasCliente))
                      : (isEquipamentoNotEmpty && (widget.isClientAndService || hasCliente));
                },
                onSelected: (tecnico) {
                  widget.form.setNomeTecnico(tecnico.nome);
                  widget.form.setIdTecnico(tecnico.id);
                },
                isForListScreen: widget.isForListScreen,
              ),
              DropdownInputField(
                hint: "Horário*",
                dropdownValues: Constants.horarioPrevisto,
                valueNotifier: widget.form.horario,
                validator: validator.byField(widget.form, ErrorCodeKey.horario.name),
                onChanged: widget.form.setHorario,
                shouldExpand: true,
                enabled: isFieldEnabled("horario"),
              ),
              DropdownInputField(
                hint: "Filial*",
                dropdownValues: Constants.filiais,
                valueNotifier: widget.form.filial,
                validator: validator.byField(widget.form, ErrorCodeKey.filial.name),
                onChanged: widget.form.setFilial,
                shouldExpand: true,
                enabled: isFieldEnabled("filial"),
              ),
              DatePickerInputField(
                startNewRow: true,
                shouldExpand: widget.isUpdate,
                hint: "Data Prevista",
                valueNotifier: widget.form.dataAtendimentoPrevisto,
                validator: validator.byField(widget.form, ErrorCodeKey.dataAtendimentoPrevisto.name),
                onChanged: widget.form.setDataAtendimentoPrevisto,
                enabled: isFieldEnabled("dataAtendimentoPrevisto"),
              ),
              if (widget.isUpdate) ...[
                DatePickerInputField(
                  shouldExpand: true,
                  hint: "Data Efetiva*",
                  valueNotifier: widget.form.dataAtendimentoEfetivo,
                  validator: validator.byField(widget.form, ErrorCodeKey.dataAtendimentoEfetivo.name),
                  onChanged: widget.form.setDataAtendimentoEfetivo,
                  enabled: isFieldEnabled("dataAtendimentoEfetivo"),
                ),
                TextFormInputField(
                  hint: "9.999,99",
                  label: "Valor Serviço*",
                  maxLength: 13,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  valueNotifier: widget.form.valor,
                  onChanged: widget.form.setValorServico,
                  validator: validator.byField(widget.form, ErrorCodeKey.valor.name),
                  shouldExpand: true,
                  startNewRow: true,
                  formatter: InputMasks.currency,
                  enabled: isFieldEnabled("valorServico"),
                ),
                TextFormInputField(
                  hint: "9.999,99",
                  label: "Valor Peças*",
                  maxLength: 13,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  valueNotifier: widget.form.valorPecas,
                  onChanged: widget.form.setValorPecas,
                  validator: validator.byField(widget.form, ErrorCodeKey.valorPecas.name),
                  formatter: InputMasks.currency,
                  shouldExpand: true,
                  enabled: isFieldEnabled("valorPecas"),
                ),
                TextFormInputField(
                  hint: "9.999,99",
                  label: "Valor Comissão",
                  maxLength: 13,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  valueNotifier: widget.form.valorComissao,
                  onChanged: widget.form.setValorComissao,
                  validator: validator.byField(widget.form, ErrorCodeKey.valorComissao.name),
                  shouldExpand: true,
                  startNewRow: true,
                  formatter: InputMasks.currency,
                  enabled: false,
                ),
                DropdownInputField(
                  hint: "Forma de Pagamento*",
                  dropdownValues: Constants.formasPagamento,
                  valueNotifier: widget.form.formaPagamento,
                  validator: validator.byField(widget.form, ErrorCodeKey.formaPagamento.name),
                  onChanged: widget.form.setFormaPagamento,
                  shouldExpand: true,
                  enabled: isFieldEnabled("formaPagamento"),
                ),
                DatePickerInputField(
                  startNewRow: true,
                  shouldExpand: true,
                  valueNotifier: widget.form.dataPagamentoComissao,
                  onChanged: widget.form.setDataPagamentoComissao,
                  validator: validator.byField(widget.form, ErrorCodeKey.dataPagamentoComissao.name),
                  hint: "Data Pgto. comissão",
                  enabled: isFieldEnabled("dataPagamentoComissao"),
                ),
                DatePickerInputField(
                  shouldExpand: true,
                  valueNotifier: widget.form.dataFechamento,
                  onChanged: widget.form.setDataFechamento,
                  validator: validator.byField(widget.form, ErrorCodeKey.dataFechamento.name),
                  hint: "Data Fechamento*",
                  enabled: isFieldEnabled("dataFechamento"),
                ),
                DropdownInputField(
                  hint: "Situação*",
                  dropdownValues: Constants.situationServiceList,
                  valueNotifier: widget.form.situacao,
                  validator: validator.byField(widget.form, ErrorCodeKey.situacao.name),
                  onChanged: handleSituationChange,
                  enabled: isFieldEnabled("situacao"),
                ),
                DatePickerInputField(
                  startNewRow: true,
                  shouldExpand: true,
                  hint: "Data Início da Garantia*",
                  valueNotifier: widget.form.dataInicioGarantia,
                  validator: validator.byField(widget.form, ErrorCodeKey.dataInicioGarantia.name),
                  onChanged: widget.form.setDataInicioGarantia,
                  enabled: isFieldEnabled("dataInicioGarantia"),
                ),
                DatePickerInputField(
                  shouldExpand: true,
                  hint: "Data Final da Garantia*",
                  valueNotifier: widget.form.dataFinalGarantia,
                  validator: validator.byField(widget.form, ErrorCodeKey.dataFinalGarantia.name),
                  onChanged: widget.form.setDataFinalGarantia,
                  enabled: isFieldEnabled("dataFinalGarantia"),
                ),
              ],
              TextFormInputField(
                hint: "Descrição/Observação...",
                label: "Descrição/Observação*",
                maxLength: 255,
                keyboardType: TextInputType.multiline,
                valueNotifier: widget.form.descricao,
                validator: validator.byField(widget.form, ErrorCodeKey.descricao.name),
                onChanged: widget.form.setDescricao,
                enabled: isFieldEnabled("descricao"),
              ),
            ];
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _situationNotifier.dispose();
    super.dispose();
  }
}
