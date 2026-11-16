import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/shared/models/enums/error_code_key.dart';
import 'package:serv_oeste/features/servico/domain/rules/service_field_rules.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';
import 'package:serv_oeste/shared/validation/validator.dart';

class ServicoValidator extends LucidValidator<ServicoForm>
    with BackendErrorsValidator {
  final ServicoForm servicoForm;
  final bool isUpdate;

  ServicoValidator({required this.servicoForm, this.isUpdate = false}) {
    _initializeRules();
  }

  void _initializeRules() {
    ruleFor(
          (servico) => servico.equipamento.value,
          key: ErrorCodeKey.equipamento.name,
        )
        .must(
          (equipamento) => equipamento != "",
          "Selecione um equipamento!",
          ErrorCodeKey.equipamento.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.equipamento.name,
        );

    ruleFor((servico) => servico.marca.value, key: ErrorCodeKey.marca.name)
        .must(
          (marca) => marca != "",
          "Selecione a marca do equipamento!",
          ErrorCodeKey.marca.name,
        )
        .customValidExternalErrors(externalErrors, ErrorCodeKey.marca.name);

    ruleFor((servico) => servico.filial.value, key: ErrorCodeKey.filial.name)
        .must(
          (filial) => filial != "" && filial != "Selecione uma filial*",
          "Selecione uma filial!",
          ErrorCodeKey.filial.name,
        )
        .customValidExternalErrors(externalErrors, ErrorCodeKey.filial.name);

    ruleFor(
          (servico) => servico.dataAtendimentoPrevisto.value,
          key: ErrorCodeKey.dataAtendimentoPrevisto.name,
        )
        .when(
          (servico) =>
              servico.dataAtendimentoPrevisto.value.isNotEmpty ||
              _shouldValidate(servico, ErrorCodeKey.dataAtendimentoPrevisto),
        )
        .customValidNotSunday(code: ErrorCodeKey.dataAtendimentoPrevisto.name)
        .must(
          (dataAtendimentoPrevisto) => dataAtendimentoPrevisto != "",
          "Data de atendimento previsto é obrigatória",
          ErrorCodeKey.dataAtendimentoPrevisto.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.dataAtendimentoPrevisto.name,
        );

    ruleFor(
          (servico) => servico.descricao.value,
          key: ErrorCodeKey.descricao.name,
        )
        .when((servico) => _shouldValidate(servico, ErrorCodeKey.descricao))
        .must(
          (descricao) => descricao != "",
          "A Descrição é obrigatória",
          ErrorCodeKey.descricao.name,
        )
        .minLength(
          10,
          message: "É necessário o mínimo de 10 caracteres!",
          code: ErrorCodeKey.descricao.name,
        )
        .must(
          (descricao) => descricao.split(" ").length > 2,
          "Insira ao menos 3 palavras!",
          ErrorCodeKey.descricao.name,
        )
        .customValidExternalErrors(externalErrors, ErrorCodeKey.descricao.name);

    ruleFor((servico) => servico.valor.value, key: ErrorCodeKey.valor.name)
        .when((servico) => _shouldValidate(servico, ErrorCodeKey.valor))
        .must(
          (valor) => valor != "",
          "O Valor do serviço é obrigatório",
          ErrorCodeKey.valor.name,
        )
        .customValidExternalErrors(externalErrors, ErrorCodeKey.valor.name);

    ruleFor(
          (servico) => servico.valorPecas.value,
          key: ErrorCodeKey.valorPecas.name,
        )
        .when((servico) => _shouldValidate(servico, ErrorCodeKey.valorPecas))
        .must(
          (valorPecas) => valorPecas != "",
          "O Valor das peças é obrigatório",
          ErrorCodeKey.valorPecas.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.valorPecas.name,
        );

    ruleFor(
          (servico) => servico.dataAtendimentoEfetivo.value,
          key: ErrorCodeKey.dataAtendimentoEfetivo.name,
        )
        .when(
          (servico) =>
              _shouldValidate(servico, ErrorCodeKey.dataAtendimentoEfetivo),
        )
        .must(
          (dataAtendimentoEfetivo) => dataAtendimentoEfetivo != "",
          "A Data efetiva é obrigatória",
          ErrorCodeKey.dataAtendimentoEfetivo.name,
        )
        .must(
          (dataAtendimentoEfetivo) {
            final dataEfetiva = Formatters.parseDate(dataAtendimentoEfetivo);

            if (dataEfetiva == null) return true;

            final hoje = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

            return !dataEfetiva.isAfter(hoje);
          },
          "A Data efetiva não pode ser posterior à data atual",
          ErrorCodeKey.dataAtendimentoEfetivo.name,
        )
        .must(
          (dataAtendimentoEfetivo) {
            final dataEfetiva = Formatters.parseDate(dataAtendimentoEfetivo);

            final dataAbertura = Formatters.parseDate(
              servicoForm.dataAtendimentoAbertura.value,
            );

            if (dataEfetiva == null || dataAbertura == null) {
              return true;
            }

            return !dataEfetiva.isBefore(dataAbertura);
          },
          "A Data efetiva não pode ser anterior à data de abertura",
          ErrorCodeKey.dataAtendimentoEfetivo.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.dataAtendimentoEfetivo.name,
        );

    ruleFor(
          (servico) => servico.dataInicioGarantia.value,
          key: ErrorCodeKey.dataInicioGarantia.name,
        )
        .when(
          (servico) =>
              _shouldValidate(servico, ErrorCodeKey.dataInicioGarantia),
        )
        .must(
          (dataInicioGarantia) => dataInicioGarantia != "",
          "A Data início da garantia é obrigatória",
          ErrorCodeKey.dataInicioGarantia.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.dataInicioGarantia.name,
        );

    ruleFor(
          (servico) => servico.dataFinalGarantia.value,
          key: ErrorCodeKey.dataFinalGarantia.name,
        )
        .when(
          (servico) => _shouldValidate(servico, ErrorCodeKey.dataFinalGarantia),
        )
        .must(
          (dataFinalGarantia) => dataFinalGarantia != "",
          "A Data final da garantia é obrigatória",
          ErrorCodeKey.dataFinalGarantia.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.dataFinalGarantia.name,
        );

    ruleFor(
          (servico) => servico.formaPagamento.value,
          key: ErrorCodeKey.formaPagamento.name,
        )
        .when(
          (servico) => _shouldValidate(servico, ErrorCodeKey.formaPagamento),
        )
        .must(
          (formaPagamento) => formaPagamento != "",
          "A Forma de pagamento é obrigatória",
          ErrorCodeKey.formaPagamento.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.formaPagamento.name,
        );

    ruleFor((servico) => servico.periodo.value, key: ErrorCodeKey.periodo.name)
        .when((servico) => _shouldValidate(servico, ErrorCodeKey.periodo))
        .must(
          (periodo) => periodo != null,
          "Selecione um horário!",
          ErrorCodeKey.periodo.name,
        )
        .customValidExternalErrors(externalErrors, ErrorCodeKey.periodo.name);

    ruleFor(
          (servico) => servico.dataPagamentoComissao.value,
          key: ErrorCodeKey.dataPagamentoComissao.name,
        )
        .when(
          (servico) =>
              _shouldValidate(servico, ErrorCodeKey.dataPagamentoComissao),
        )
        .must(
          (dataPagamentoComissao) => dataPagamentoComissao != "",
          "Data do pagamento comissao é obrigatória",
          ErrorCodeKey.dataPagamentoComissao.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.dataPagamentoComissao.name,
        );

    ruleFor(
          (servico) => servico.dataFechamento.value,
          key: ErrorCodeKey.dataFechamento.name,
        )
        .when(
          (servico) => _shouldValidate(servico, ErrorCodeKey.dataFechamento),
        )
        .must(
          (dataFechamento) => dataFechamento != "",
          "A Data de encerramento é obrigatória",
          ErrorCodeKey.dataFechamento.name,
        )
        .customValidExternalErrors(
          externalErrors,
          ErrorCodeKey.dataFechamento.name,
        );
  }

  bool _shouldValidate(ServicoForm form, ErrorCodeKey field) =>
      externalErrors.containsKey(field.name) ||
      (isUpdate &&
          form.situacao.value != null &&
          ServiceFieldRules.isRequired(field, form.situacao.value!));

  @override
  ValidationResult validate(ServicoForm entity, {List<String>? ruleSets}) {
    final result = super.validate(entity, ruleSets: ruleSets);

    return result;
  }
}
