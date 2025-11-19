import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';

class ServicoValidator extends LucidValidator<ServicoForm> with BackendErrorsValidator {
  final bool isUpdate;
  final List<String> situacoesOpcionais = [
    "Orçamento aprovado",
    "Aguardando cliente retirar",
    "Não retira há 3 meses",
  ];

  bool Function(String fieldName)? isFieldEnabled;

  ServicoValidator({this.isUpdate = false, this.isFieldEnabled}) {
    _initializeRules();
  }

  void _initializeRules() {
    ruleFor((servico) => servico.equipamento.value, key: ErrorCodeKey.equipamento.name)
        .when((servico) => _shouldValidateField(ErrorCodeKey.equipamento.name))
        .must((equipamento) => equipamento != "", "Selecione um equipamento!", ErrorCodeKey.equipamento.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.equipamento.name);

    ruleFor((servico) => servico.marca.value, key: ErrorCodeKey.marca.name)
        .when((servico) => _shouldValidateField(ErrorCodeKey.marca.name))
        .must((marca) => marca != "", "Selecione a marca do equipamento!", ErrorCodeKey.marca.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.marca.name);

    ruleFor((servico) => servico.filial.value, key: ErrorCodeKey.filial.name)
        .when((servico) => _shouldValidateField(ErrorCodeKey.filial.name))
        .must((filial) => filial != "" && filial != "Selecione uma filial*", "Selecione uma filial!", ErrorCodeKey.filial.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.filial.name);

    ruleFor((servico) => servico.dataAtendimentoPrevisto.value, key: ErrorCodeKey.dataAtendimentoPrevisto.name)
        .when((servico) => _shouldValidateField(ErrorCodeKey.dataAtendimentoPrevisto.name) && servico.situacao.value != "Cancelado")
        .customValidNotSunday(code: ErrorCodeKey.dataAtendimentoPrevisto.name)
        .must((dataAtendimentoPrevisto) => dataAtendimentoPrevisto != "", "Data de atendimento previsto é obrigatória", ErrorCodeKey.dataAtendimentoPrevisto.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.dataAtendimentoPrevisto.name);

    ruleFor((servico) => servico.descricao.value, key: ErrorCodeKey.descricao.name)
        .when((servico) => _shouldValidateField(ErrorCodeKey.descricao.name))
        .must((descricao) => descricao != "", "O campo 'descrição' é obrigatório!", ErrorCodeKey.descricao.name)
        .minLength(10, message: "É necessário o mínimo de 10 caracteres!", code: ErrorCodeKey.descricao.name)
        .must((descricao) => descricao.split(" ").length > 2, "Insira ao menos 3 palavras!", ErrorCodeKey.descricao.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.descricao.name);

    ruleFor((servico) => servico.valor.value, key: ErrorCodeKey.valor.name)
        .when((servico) =>
            _shouldValidateField(ErrorCodeKey.valor.name) &&
            isUpdate &&
            ![
              'Aguardando agendamento',
              'Aguardando atendimento',
              'Cancelado',
              'Sem defeito',
              'Aguardando orçamento',
            ].contains(servico.situacao.value))
        .must((valor) => valor != "", "Valor do serviço é obrigatório", ErrorCodeKey.valor.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.valor.name);

    ruleFor((servico) => servico.valorPecas.value, key: ErrorCodeKey.valorPecas.name)
        .when((servico) =>
            _shouldValidateField(ErrorCodeKey.valorPecas.name) &&
            isUpdate &&
            ![
              'Aguardando agendamento',
              'Aguardando atendimento',
              'Cancelado',
              'Sem defeito',
              'Aguardando orçamento',
            ].contains(servico.situacao.value))
        .must((valorPecas) => valorPecas != "", "Valor das peças é obrigatório", ErrorCodeKey.valorPecas.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.valorPecas.name);

    ruleFor((servico) => servico.dataAtendimentoEfetivo.value, key: ErrorCodeKey.dataAtendimentoEfetivo.name)
        .when((servico) =>
            _shouldValidateField(ErrorCodeKey.dataAtendimentoEfetivo.name) &&
            isUpdate &&
            ![
              'Aguardando agendamento',
              'Aguardando atendimento',
              'Cancelado',
            ].contains(servico.situacao.value))
        .must((dataAtendimentoEfetivo) => dataAtendimentoEfetivo != "", "Data efetiva é obrigatória", ErrorCodeKey.dataAtendimentoEfetivo.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.dataAtendimentoEfetivo.name);

    ruleFor((servico) => servico.dataInicioGarantia.value, key: ErrorCodeKey.dataInicioGarantia.name)
        .when((servico) =>
            _shouldValidateField(ErrorCodeKey.dataInicioGarantia.name) &&
            isUpdate &&
            ![
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
            ].contains(servico.situacao.value))
        .must((dataInicioGarantia) => dataInicioGarantia != "", "Data início da garantia é obrigatória", ErrorCodeKey.dataInicioGarantia.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.dataInicioGarantia.name);

    ruleFor((servico) => servico.dataFinalGarantia.value, key: ErrorCodeKey.dataFinalGarantia.name)
        .when((servico) =>
            _shouldValidateField(ErrorCodeKey.dataFinalGarantia.name) &&
            isUpdate &&
            ![
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
            ].contains(servico.situacao.value))
        .must((dataFinalGarantia) => dataFinalGarantia != "", "Data final da garantia é obrigatória", ErrorCodeKey.dataFinalGarantia.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.dataFinalGarantia.name);

    ruleFor((servico) => servico.formaPagamento.value, key: ErrorCodeKey.formaPagamento.name)
        .when((servico) =>
            _shouldValidateField(ErrorCodeKey.formaPagamento.name) &&
            !situacoesOpcionais.contains(servico.situacao.value) &&
            isUpdate &&
            ![
              'Aguardando agendamento',
              'Aguardando atendimento',
              'Cancelado',
              'Sem defeito',
              'Aguardando orçamento',
              'Aguardando aprovação do cliente',
              'Não aprovado pelo cliente',
              'Compra',
            ].contains(servico.situacao.value))
        .must((formaPagamento) => formaPagamento != "", "Forma de pagamento é obrigatória", ErrorCodeKey.formaPagamento.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.formaPagamento.name);

    ruleFor((servico) => servico.horario.value, key: ErrorCodeKey.horario.name)
        .when((servico) => _shouldValidateField(ErrorCodeKey.horario.name) && servico.situacao.value != "Cancelado")
        .must((horario) => horario != "", "Selecione um horário!", ErrorCodeKey.horario.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.horario.name);

    ruleFor((servico) => servico.dataPagamentoComissao.value, key: ErrorCodeKey.dataPagamentoComissao.name)
        .when((servico) => _shouldValidateField(ErrorCodeKey.dataPagamentoComissao.name) && isUpdate)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.dataPagamentoComissao.name);

    ruleFor((servico) => servico.dataFechamento.value, key: ErrorCodeKey.dataFechamento.name)
        .when((servico) =>
            _shouldValidateField(ErrorCodeKey.dataFechamento.name) &&
            isUpdate &&
            ![
              'Aguardando agendamento',
              'Aguardando atendimento',
              'Aguardando orçamento',
              'Aguardando aprovação do cliente',
              'Orçamento aprovado',
              'Aguardando cliente retirar',
              'Cortesia',
              'Garantia',
            ].contains(servico.situacao.value))
        .must((dataFechamento) => dataFechamento != "", "Data de encerramento é obrigatória", ErrorCodeKey.dataFechamento.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.dataFechamento.name);
  }

  bool _shouldValidateField(String fieldName) {
    if (isFieldEnabled == null) return true;
    return isFieldEnabled!(fieldName);
  }

  @override
  ValidationResult validate(ServicoForm entity) {
    final result = super.validate(entity);

    return result;
  }
}
