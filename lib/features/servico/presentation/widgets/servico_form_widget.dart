import 'package:flutter/material.dart';
import 'package:serv_oeste/core/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/features/servico/domain/entities/enums/service_status.dart';
import 'package:serv_oeste/features/servico/domain/entities/enums/service_periodo.dart';
import 'package:serv_oeste/features/servico/domain/rules/service_field_rules.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_filter.dart';
import 'package:serv_oeste/features/tecnico/presentation/widgets/tecnico_table_modal.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_input_field.dart';
import 'package:serv_oeste/features/tecnico/presentation/widgets/tecnico_search_field.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/shared/services/specialty_cache.dart';
import 'package:serv_oeste/shared/models/enums/error_code_key.dart';
import 'package:serv_oeste/features/servico/domain/validators/servico_validator.dart';
import 'package:serv_oeste/shared/validation/validator.dart';
import 'package:serv_oeste/shared/widgets/screen/base_entity_form.dart';
import 'package:serv_oeste/shared/utils/formatters/input_masks.dart';

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

  final ValueNotifier<ServiceStatus?> _situationNotifier = ValueNotifier(null);
  late bool enabled;

  @override
  void initState() {
    super.initState();

    formKey = widget.formKey ?? GlobalKey<FormState>();

    validator =
        widget.validator ??
        ServicoValidator(servicoForm: widget.form, isUpdate: widget.isUpdate);

    nameTecnicoController = widget.nameTecnicoController;

    widget.form.situacao.addListener(_onFormSituationChanged);
    _situationNotifier.value = widget.form.situacao.value;

    enabled = isInputEnabled();
  }

  void _onFormSituationChanged() {
    _situationNotifier.value = widget.form.situacao.value;
  }

  bool isInputEnabled() {
    if (widget.isUpdate) return true;
    return (widget.isClientAndService || widget.form.idCliente.value != null);
  }

  bool isFieldEnabled(ErrorCodeKey? field) {
    if (!widget.isUpdate) return enabled;
    final status = _situationNotifier.value;
    if (status == null) return true;
    return field == null || !ServiceFieldRules.isDisabled(field, status);
  }

  int getServiceLevel(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.aguardandoAgendamento => 0,
      ServiceStatus.aguardandoAtendimento => 1,
      ServiceStatus.cancelado ||
      ServiceStatus.semDefeito ||
      ServiceStatus.aguardandoOrcamento ||
      ServiceStatus.aguardandoAprovacaoCliente => 2,
      ServiceStatus.compra ||
      ServiceStatus.naoAprovadoPeloCliente ||
      ServiceStatus.orcamentoAprovado => 3,
      ServiceStatus.resolvido || ServiceStatus.garantia => 4,
    };
  }

  void updateServiceSituation(ServiceStatus? value) {
    widget.form.setSituacao(value);
    _situationNotifier.value = widget.form.situacao.value;
    if (value != null) _clearDisabledFields(value);
  }

  void _clearDisabledFields(ServiceStatus status) {
    final clearers = <ErrorCodeKey, void Function()>{
      ErrorCodeKey.dataAtendimentoEfetivo: () =>
          widget.form.setDataAtendimentoEfetivo(""),
      ErrorCodeKey.valor: () => widget.form.setValorServico(""),
      ErrorCodeKey.valorPecas: () => widget.form.setValorPecas(""),
      ErrorCodeKey.valorComissao: () => widget.form.setValorComissao(""),
      ErrorCodeKey.formaPagamento: () => widget.form.setFormaPagamento(""),
      ErrorCodeKey.dataPagamentoComissao: () =>
          widget.form.setDataPagamentoComissao(""),
      ErrorCodeKey.dataFechamento: () => widget.form.setDataFechamento(""),
      ErrorCodeKey.dataInicioGarantia: () =>
          widget.form.setDataInicioGarantia(""),
      ErrorCodeKey.dataFinalGarantia: () => widget.form.setDataFinalGarantia(""),
    };
    for (final entry in clearers.entries) {
      if (ServiceFieldRules.isDisabled(entry.key, status)) entry.value();
    }
  }

  void handleSituationChange(String value) {
    final ServiceStatus? previousStatus = widget.form.situacao.value;
    final int currentLevel = previousStatus == null
        ? -1
        : getServiceLevel(previousStatus);
    final int newLevel = getServiceLevel(ServiceStatus.fromJson(value));

    if (currentLevel > newLevel) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (previousStatus != null) {
                      widget.form.setSituacao(previousStatus);
                    }
                  },
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
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
                    updateServiceSituation(ServiceStatus.fromJson(value));
                  },
                  child: Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            );
          },
        );
        if (confirm == true) {
          updateServiceSituation(ServiceStatus.fromJson(value));
        }
      });
    } else {
      updateServiceSituation(ServiceStatus.fromJson(value));
    }
  }

  bool _enableTecnico() {
    bool isEquipamentoNotEmpty = widget.form.equipamento.value.isNotEmpty;
    bool hasCliente = widget.form.idCliente.value != null;

    if (widget.isUpdate) {
      return isFieldEnabled(ErrorCodeKey.tecnico) && (isEquipamentoNotEmpty || hasCliente);
    }

    return (widget.isClientAndService)
        ? (isEquipamentoNotEmpty || (!widget.isClientAndService || hasCliente))
        : (isEquipamentoNotEmpty && (widget.isClientAndService || hasCliente));
  }

  void _setTableValues(
    String nomeTecnico,
    String data,
    String periodo,
    int idTecnico,
  ) {
    widget.nameTecnicoController.text = nomeTecnico;
    widget.form.setNomeTecnico(nomeTecnico);
    widget.form.setDataAtendimentoPrevisto(data);
    widget.form.setHorario(periodo);
    widget.form.setIdTecnico(idTecnico);
  }

  void _onShowAvailabilityTechnicianTable() {
    int idEspecialidade = 12;
    final int? idFromCache = context.read<SpecialtyCache>().idByConhecimento(
      widget.form.equipamento.value,
    );
    if (idFromCache != null) {
      idEspecialidade = idFromCache;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TecnicoTableModal(
          especialidadeId: idEspecialidade,
          setValuesAvailabilityTechnicianTable: _setTableValues,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    enabled = isInputEnabled();

    return ValueListenableBuilder<ServiceStatus?>(
      valueListenable: _situationNotifier,
      builder: (context, situation, child) {
        return BaseEntityForm<ServicoBloc, ServicoState>(
          bloc: widget.bloc,
          formKey: formKey,
          submitText: widget.submitText,
          isLoading: (state) => state is ServicoLoadingState,
          isSuccess: (state) => widget.isUpdate
              ? state is ServicoUpdateSuccessState
              : state is ServicoRegisterSuccessState,
          getSuccessMessage: (state) {
            return widget.successMessage;
          },
          isError: (state) => state is ServicoErrorState,
          getErrorMessage: (state) {
            if (state is ServicoErrorState) {
              final error = state.error;
              final knownKeys = ErrorCodeKey.values
                  .where((key) => key != ErrorCodeKey.global)
                  .map((key) => key.name)
                  .toSet();
              final generalErrors = error.errors.entries
                  .map(
                    (entry) => MapEntry(
                      BackendErrorsValidator.backendKeyAliases[entry.key] ??
                          entry.key,
                      entry.value,
                    ),
                  )
                  .where(
                    (entry) =>
                        !knownKeys.contains(entry.key) ||
                        (entry.key == ErrorCodeKey.cliente.name &&
                            !validator.requiresCliente),
                  )
                  .expand((entry) => entry.value)
                  .toList();
              if (generalErrors.isNotEmpty) {
                return generalErrors.join('\n');
              }
              if (error.errors.isNotEmpty) return "";
              return error.detail.isNotEmpty
                  ? error.detail
                  : error.title.isNotEmpty
                    ? error.title
                    : "Erro ao realizar operação";
            }
            return "Erro ao realizar operação";
          },
          onError: (state) {
            if (state is ServicoErrorState) {
              validator.applyBackendError(state.error);
              formKey.currentState?.validate();
              validator.cleanExternalErrors();
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
            final SpecialtyCache specialtyCache = context
                .read<SpecialtyCache>();
            return [
              DropdownSearchInputField(
                hint: "Equipamento*",
                validator: validator.byField(
                  widget.form,
                  ErrorCodeKey.equipamento.name,
                ),
                valueNotifier: widget.form.equipamento,
                dropdownValues: specialtyCache.hasData
                    ? specialtyCache.activeConhecimentosOrdered()
                    : Constants.equipamentosFallback,
                onChanged: widget.form.setEquipamento,
                enabled: isFieldEnabled(ErrorCodeKey.equipamento),
                shouldExpand: widget.isUpdate,
              ),
              DropdownSearchInputField(
                hint: "Marca*",
                validator: validator.byField(
                  widget.form,
                  ErrorCodeKey.marca.name,
                ),
                valueNotifier: widget.form.marca,
                dropdownValues: Constants.marcas,
                onChanged: widget.form.setMarca,
                enabled: isFieldEnabled(ErrorCodeKey.marca),
                shouldExpand: widget.isUpdate,
              ),
              CustomWidgetField(
                shouldExpand: true,
                startNewRow: true,
                flex: 1,
                child: TecnicoSearchField(
                  label: "Nome do Técnico*",
                  tooltipMessage: "Selecione um equipamento para continuar",
                  tecnicoBloc: widget.tecnicoBloc,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.tecnico.name,
                  ),
                  controller: nameTecnicoController,
                  onChanged: widget.form.setNomeTecnico,
                  onSearchStart: () => widget.form.setIdTecnico,
                  listenTo: [widget.form.equipamento, widget.form.idCliente],
                  searchFilter: () =>
                      TecnicoFilter(equipamento: widget.form.equipamento.value),
                  enabledCalculator: _enableTecnico,
                  onSelected: (tecnico) {
                    widget.form.setNomeTecnico(tecnico.nome);
                    widget.form.setIdTecnico(tecnico.id);
                  },
                  isForListScreen: widget.isForListScreen,
                ),
              ),
              ButtonInputField(
                shouldExpand: true,
                flex: 1,
                valueNotifier: widget.form.equipamento,
                text: "Verificar disponibilidade dos técnicos",
                tooltipMessage: "Selecione um equipamento para continuar",
                onPressed: _onShowAvailabilityTechnicianTable,
                enabledCalculator: _enableTecnico,
              ),
              DropdownInputField(
                startNewRow: true,
                hint: "Horário*",
                dropdownValues: ServicePeriodo.values
                    .map((periodo) => periodo.label)
                    .toList(),
                valueNotifier: widget.form.periodoLabel,
                validator: validator.byField(
                  widget.form,
                  ErrorCodeKey.periodo.name,
                ),
                onChanged: widget.form.setHorario,
                shouldExpand: true,
                enabled: isFieldEnabled(ErrorCodeKey.periodo),
              ),
              DropdownInputField(
                hint: "Filial*",
                dropdownValues: Constants.filiais,
                valueNotifier: widget.form.filial,
                validator: validator.byField(
                  widget.form,
                  ErrorCodeKey.filial.name,
                ),
                onChanged: widget.form.setFilial,
                shouldExpand: true,
                enabled: isFieldEnabled(ErrorCodeKey.filial),
              ),
              if (widget.isUpdate)
                DropdownInputField(
                  hint: "Situação*",
                  dropdownValues: ServiceStatus.labels,
                  valueNotifier: widget.form.situacaoLabel,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.situacao.name,
                  ),
                  onChanged: handleSituationChange,
                  enabled: isFieldEnabled(ErrorCodeKey.situacao),
                ),
              DatePickerInputField(
                startNewRow: true,
                shouldExpand: widget.isUpdate,
                hint: "Data Prevista*",
                valueNotifier: widget.form.dataAtendimentoPrevisto,
                validator: validator.byField(
                  widget.form,
                  ErrorCodeKey.dataAtendimentoPrevisto.name,
                ),
                onChanged: widget.form.setDataAtendimentoPrevisto,
                enabled: isFieldEnabled(ErrorCodeKey.dataAtendimentoPrevisto),
                allowPastDates: true,
              ),
              if (widget.isUpdate) ...[
                DatePickerInputField(
                  shouldExpand: true,
                  hint: "Data Efetiva*",
                  valueNotifier: widget.form.dataAtendimentoEfetivo,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.dataAtendimentoEfetivo.name,
                  ),
                  onChanged: widget.form.setDataAtendimentoEfetivo,
                  enabled: isFieldEnabled(ErrorCodeKey.dataAtendimentoEfetivo),
                  allowPastDates: true,
                  allowFutureDates: false,
                ),
                TextFormInputField(
                  hint: "9.999,99",
                  label: "Valor Serviço*",
                  maxLength: 13,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  valueNotifier: widget.form.valor,
                  onChanged: widget.form.setValorServico,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.valor.name,
                  ),
                  shouldExpand: true,
                  startNewRow: true,
                  formatter: InputMasks.currency,
                  enabled: isFieldEnabled(ErrorCodeKey.valor),
                ),
                TextFormInputField(
                  hint: "9.999,99",
                  label: "Valor Peças*",
                  maxLength: 13,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  valueNotifier: widget.form.valorPecas,
                  onChanged: widget.form.setValorPecas,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.valorPecas.name,
                  ),
                  formatter: InputMasks.currency,
                  shouldExpand: true,
                  enabled: isFieldEnabled(ErrorCodeKey.valorPecas),
                ),
                TextFormInputField(
                  hint: "9.999,99",
                  label: "Valor Comissão",
                  maxLength: 13,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  valueNotifier: widget.form.valorComissao,
                  onChanged: widget.form.setValorComissao,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.valorComissao.name,
                  ),
                  shouldExpand: true,
                  startNewRow: true,
                  formatter: InputMasks.currency,
                  enabled: false,
                ),
                DropdownInputField(
                  hint: "Forma de Pagamento***",
                  dropdownValues: Constants.formasPagamento,
                  valueNotifier: widget.form.formaPagamento,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.formaPagamento.name,
                  ),
                  onChanged: widget.form.setFormaPagamento,
                  shouldExpand: true,
                  enabled: isFieldEnabled(ErrorCodeKey.formaPagamento),
                ),
                DatePickerInputField(
                  startNewRow: true,
                  shouldExpand: true,
                  valueNotifier: widget.form.dataPagamentoComissao,
                  onChanged: widget.form.setDataPagamentoComissao,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.dataPagamentoComissao.name,
                  ),
                  hint: "Data Pgto. comissão",
                  enabled: isFieldEnabled(ErrorCodeKey.dataPagamentoComissao),
                  allowPastDates: true,
                ),
                DatePickerInputField(
                  shouldExpand: true,
                  valueNotifier: widget.form.dataFechamento,
                  onChanged: widget.form.setDataFechamento,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.dataFechamento.name,
                  ),
                  hint: "Data Fechamento*",
                  enabled: isFieldEnabled(ErrorCodeKey.dataFechamento),
                  allowPastDates: true,
                ),
                DatePickerInputField(
                  startNewRow: true,
                  shouldExpand: true,
                  hint: "Data Início da Garantia*",
                  valueNotifier: widget.form.dataInicioGarantia,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.dataInicioGarantia.name,
                  ),
                  onChanged: widget.form.setDataInicioGarantia,
                  enabled: isFieldEnabled(ErrorCodeKey.dataInicioGarantia),
                  allowPastDates: true,
                ),
                DatePickerInputField(
                  shouldExpand: true,
                  hint: "Data Final da Garantia*",
                  valueNotifier: widget.form.dataFinalGarantia,
                  validator: validator.byField(
                    widget.form,
                    ErrorCodeKey.dataFinalGarantia.name,
                  ),
                  onChanged: widget.form.setDataFinalGarantia,
                  enabled: isFieldEnabled(ErrorCodeKey.dataFinalGarantia),
                  allowPastDates: true,
                ),
              ],
              TextFormInputField(
                hint: "Descrição/Observação...",
                label: "Descrição/Observação***",
                maxLength: 255,
                keyboardType: TextInputType.multiline,
                valueNotifier: widget.form.descricao,
                validator: validator.byField(
                  widget.form,
                  ErrorCodeKey.descricao.name,
                ),
                onChanged: widget.form.setDescricao,
                enabled: isFieldEnabled(ErrorCodeKey.descricao),
              ),
            ];
          },
        );
      },
    );
  }

  @override
  void dispose() {
    widget.form.situacao.removeListener(_onFormSituationChanged);
    _situationNotifier.dispose();
    super.dispose();
  }
}
