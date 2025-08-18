import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/formFields/tecnico/tecnico_search_field.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/enums/technical_status.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/validators/servico_validator.dart';
import 'package:serv_oeste/src/screens/base_entity_form.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/extensions.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class ServicoFormWidget extends StatelessWidget {
  final String submitText;
  final bool isUpdate;
  final bool isClientAndService;
  final ServicoBloc bloc;
  final TecnicoBloc tecnicoBloc;
  final ServicoValidator? validator;
  final GlobalKey<FormState>? formKey;
  final void Function() onSubmit;
  final ServicoForm form;
  final TextEditingController nameTecnicoController;

  const ServicoFormWidget({
    super.key,
    this.isUpdate = false,
    this.isClientAndService = false,
    required this.nameTecnicoController,
    required this.tecnicoBloc,
    required this.submitText,
    required this.onSubmit,
    required this.bloc,
    required this.form,
    this.validator,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = this.formKey?? GlobalKey<FormState>();
    final ServicoValidator validator = this.validator?? ServicoValidator();
    final TextEditingController nameTecnicoController = this.nameTecnicoController;
    final Map<String, List<String>> disabledSituationsByField = {
      "nomeTecnico": [
        'Aguardando agendamento',
      ],
      "horario": [
        'Aguardando agendamento',
      ],
      "dataAtendimentoPrevisto": [
        'Aguardando agendamento',
      ],
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
    final Map<String, ValueNotifier<bool>> fieldEnabledNotifiers = {
      "nomeTecnico": ValueNotifier(false),
      "horario": ValueNotifier(false),
      "dataAtendimentoPrevisto": ValueNotifier(false),
      "dataAtendimentoEfetivo": ValueNotifier(false),
      "valorServico": ValueNotifier(false),
      "valorPecas": ValueNotifier(false),
      "formaPagamento": ValueNotifier(false),
      "dataFechamento": ValueNotifier(false),
      "dataPagamentoComissao": ValueNotifier(false),
      "dataInicioGarantia": ValueNotifier(false),
      "dataFinalGarantia": ValueNotifier(false),
    };
    bool isInputEnabled() => (isClientAndService || form.idCliente.value != null);
    bool enabled = isInputEnabled();

    void updateEnabledFields() {
      String currentSituation = form.situacao.value;

      disabledSituationsByField.forEach((field, disabledSituations) {
        bool enabled = disabledSituations.contains(currentSituation);
        fieldEnabledNotifiers[field]?.value = enabled;
      });
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
      Logger().w("Atualizando situação para: $value (Nível: ${getServiceLevel(value)})");

      form.situacao.value = value;
      form.setSituacao(value);
      updateEnabledFields();
    }

    void handleSituationChange(String value) {
      final String previousValue = form.situacao.value.convertEnumStatusToString();
      final int currentLevel = getServiceLevel(previousValue);
      final int newLevel = getServiceLevel(value);

      Logger().w("Mudando de $previousValue (Nível: $currentLevel) para $value (Nível: $newLevel)");

      if (currentLevel > newLevel) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            bool? confirm = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        form.situacao.value = previousValue;
                        form.setSituacao(previousValue);
                      },
                      child: Text("Cancelar", style: TextStyle(color: Colors.grey[700], fontSize: 16)),
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
          },
        );
      }
      else {
        updateServiceSituation(value);
      }
    }

    return ListenableBuilder(
      listenable: form.idCliente,
      builder: (BuildContext context, Widget? child) {
        enabled = isInputEnabled();
        return child!;
      },
      child: BaseEntityForm<ServicoBloc, ServicoState>(
        bloc: bloc,
        formKey: formKey,
        submitText: submitText,
        isLoading: (state) => state is ServicoLoadingState,
        isSuccess: (state) => isUpdate ? state is ServicoUpdateSuccessState : state is ServicoRegisterSuccessState,
        isError: (state) => state is ServicoErrorState,
        shouldBuildButton: false,
        onSubmit: () async {
          formKey.currentState?.validate();
          final result = validator.validate(form);
          if (!result.isValid) return;

          onSubmit();
        },
        buildFields: () => [
          DropdownSearchInputField(
            hint: "Equipamento*",
            validator: validator.byField(form, ErrorCodeKey.equipamento.name),
            valueNotifier: form.equipamento,
            dropdownValues: Constants.equipamentos,
            onChanged: form.setEquipamento,
            enabled: enabled,
            shouldExpand: isUpdate,
          ), // Equipamento

          DropdownSearchInputField(
            hint: "Marca*",
            validator: validator.byField(form, ErrorCodeKey.marca.name),
            valueNotifier: form.marca,
            dropdownValues: Constants.marcas,
            onChanged: form.setMarca,
            enabled: enabled,
            shouldExpand: isUpdate,
          ), // Marca

          TecnicoSearchField(
            label: "Nome do Técnico*",
            tooltipMessage: "Selecione um equipamento para continuar",
            tecnicoBloc: tecnicoBloc,
            validator: validator.byField(form, ErrorCodeKey.tecnico.name),
            controller: nameTecnicoController,
            onChanged: form.setNomeTecnico,
            onSearchStart: () => form.setIdTecnico,
            listenTo: [
              form.equipamento,
              form.idCliente,
              if (isUpdate)
                fieldEnabledNotifiers["nomeTecnico"]!
            ],
            enabledCalculator: () {
              bool isEquipamentoNotEmpty = form.equipamento.value.isNotEmpty;
              bool hasCliente = form.idCliente.value != null;
              updateEnabledFields();
              bool isEnabled = fieldEnabledNotifiers["nomeTecnico"]!.value;

              bool isFieldEnabled = isUpdate
                  ? (isEnabled && (isEquipamentoNotEmpty || hasCliente))
                  : (isClientAndService)
                      ? (isEquipamentoNotEmpty || (!isClientAndService || hasCliente))
                      : (isEquipamentoNotEmpty && (isClientAndService || hasCliente));

              return isFieldEnabled;
            },
            onSelected: (tecnico) {
              form.setNomeTecnico(tecnico.nome);
              form.setIdTecnico(tecnico.id);
            },
            buildSearchEvent: (name) => TecnicoSearchEvent(
              nome: name,
              equipamento: form.equipamento.value,
              situacao: TechnicalStatus.ativo.status
            ),
          ), // Técnico

          DropdownInputField(
            hint: "Horário*",
            dropdownValues: Constants.dataAtendimento,
            valueNotifier: form.horario,
            validator: validator.byField(form, ErrorCodeKey.horario.name),
            onChanged: form.setHorario,
            enabled: enabled,
            listenTo: isUpdate ? [fieldEnabledNotifiers["horario"]!] : null,
            shouldExpand: true
          ), // Horário
          DropdownInputField(
            hint: "Filial*",
            dropdownValues: Constants.filiais,
            valueNotifier: form.filial,
            validator: validator.byField(form, ErrorCodeKey.filial.name),
            onChanged: form.setFilial,
            enabled: enabled,
            shouldExpand: true
          ), // Filial

          DatePickerInputField(
            startNewRow: true,
            shouldExpand: isUpdate,
            hint: "Data Prevista",
            valueNotifier: form.dataAtendimentoPrevisto,
            validator: validator.byField(form, ErrorCodeKey.dataAtendimentoPrevisto.name),
            onChanged: form.setDataAtendimentoPrevisto,
            listenTo: isUpdate ? [fieldEnabledNotifiers["dataAtendimentoPrevisto"]!] : null,
            enabled: enabled
          ), // Data Atendimento Prevista
          if (isUpdate) ...[
            DatePickerInputField(
              shouldExpand: true,
              hint: "Data Efetiva*",
              valueNotifier: form.dataAtendimentoEfetivo,
              validator: validator.byField(form, ErrorCodeKey.dataAtendimentoEfetivo.name),
              onChanged: form.setDataAtendimentoEfetivo,
              listenTo: isUpdate ? [fieldEnabledNotifiers["dataAtendimentoEfetivo"]!] : null,
              enabled: enabled
            ), // Data Atendimento Efetiva

            TextFormInputField(
              hint: "9.999,99",
              label: "Valor Serviço*",
              maxLength: 13,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              valueNotifier: form.valor,
              onChanged: form.setValorServico,
              validator: validator.byField(form, ErrorCodeKey.valor.name),
              shouldExpand: true,
              formatter: InputMasks.currency,
              listenTo: isUpdate ? [fieldEnabledNotifiers["valorServico"]!] : null,
              startNewRow: true
            ), // Valor Serviço
            TextFormInputField(
              hint: "9.999,99",
              label: "Valor Peças*",
              maxLength: 13,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              valueNotifier: form.valorPecas,
              onChanged: form.setValorPecas,
              validator: validator.byField(form, ErrorCodeKey.valorPecas.name),
              shouldExpand: true,
              listenTo: isUpdate ? [fieldEnabledNotifiers["valorPecas"]!] : null,
              formatter: InputMasks.currency,
            ), // Valor Peças

            TextFormInputField(
              hint: "9.999,99",
              label: "Valor Comissão",
              maxLength: 13,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              valueNotifier: form.valorComissao,
              onChanged: form.setValorComissao,
              validator: validator.byField(form, ErrorCodeKey.valorComissao.name),
              shouldExpand: true,
              startNewRow: true,
              formatter: InputMasks.currency,
              enabled: false,
            ), // Valor Comissão
            DropdownInputField(
              hint: "Forma de Pagamento*",
              dropdownValues: Constants.formasPagamento,
              valueNotifier: form.formaPagamento,
              validator: validator.byField(form, ErrorCodeKey.formaPagamento.name),
              onChanged: form.setFormaPagamento,
              enabled: enabled,
              listenTo: isUpdate ? [fieldEnabledNotifiers["formaPagamento"]!] : null,
              shouldExpand: true
            ), // Forma Pagamento

            DatePickerInputField(
              startNewRow: true,
              shouldExpand: true,
              valueNotifier: form.dataPagamentoComissao,
              onChanged: form.setDataPagamentoComissao,
              validator: validator.byField(form, ErrorCodeKey.dataPagamentoComissao.name),
              hint: "Data Pgto. comissão",
              listenTo: [fieldEnabledNotifiers["dataPagamentoComissao"]!],
              enabled: enabled,
            ), // Data pagamento comissão
            DatePickerInputField(
              shouldExpand: true,
              valueNotifier: form.dataFechamento,
              onChanged: form.setDataFechamento,
              validator: validator.byField(form, ErrorCodeKey.dataEncerramento.name),
              hint: "Data Encerramento*",
              listenTo: [fieldEnabledNotifiers["dataFechamento"]!],
              enabled: enabled,
            ), // Data Encerramento

            DropdownInputField(
              hint: "Situação*",
              dropdownValues: Constants.situationServiceList,
              valueNotifier: form.situacao,
              validator: validator.byField(form, ErrorCodeKey.situacao.name),
              onChanged: handleSituationChange,
              enabled: enabled,
            ), // Situação

            DatePickerInputField(
              startNewRow: true,
              shouldExpand: true,
              hint: "Data Início da Garantia*",
              valueNotifier: form.dataInicioGarantia,
              validator: validator.byField(form, ErrorCodeKey.dataInicioGarantia.name),
              onChanged: form.setDataInicioGarantia,
              listenTo: [fieldEnabledNotifiers["dataInicioGarantia"]!],
              enabled: enabled
            ), // Data Inicio Garantia
            DatePickerInputField(
              shouldExpand: true,
              hint: "Data Final da Garantia*",
              valueNotifier: form.dataFinalGarantia,
              validator: validator.byField(form, ErrorCodeKey.dataFinalGarantia.name),
              onChanged: form.setDataFinalGarantia,
              listenTo: [fieldEnabledNotifiers["dataFinalGarantia"]!],
              enabled: enabled
            ), // Data Final Garantia
          ],

          TextFormInputField(
            hint: "Descrição/Observação...",
            label: "Descrição/Observação*",
            maxLength: 255,
            keyboardType: TextInputType.multiline,
            valueNotifier: form.descricao,
            validator: validator.byField(form, ErrorCodeKey.descricao.name),
            onChanged: form.setDescricao,
            enabled: enabled
          ), // Descrição
        ],
      ),
    );
  }
}
