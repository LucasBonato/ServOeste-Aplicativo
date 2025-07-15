import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';

class ServicoValidator extends LucidValidator<ServicoForm> with BackendErrorsValidator {
  final bool isUpdate;

  ServicoValidator({this.isUpdate = false}) {
    ruleFor((servico) => servico.equipamento.value, key: ErrorCodeKey.equipamento.name)
        .must((equipamento) => equipamento != "", "Selecione um equipamento!", ErrorCodeKey.equipamento.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.equipamento.name);

    ruleFor((servico) => servico.marca.value, key: ErrorCodeKey.marca.name)
        .must((marca) => marca != "", "Selecione a marca do equipamento!", ErrorCodeKey.marca.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.marca.name);

    ruleFor((servico) => servico.filial.value, key: ErrorCodeKey.filial.name)
        .must((filial) => filial != "" || filial != "Selecione uma filial*", "Selecione uma filial!", ErrorCodeKey.filial.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.filial.name);

    ruleFor((servico) => servico.dataAtendimentoPrevisto.value, key: ErrorCodeKey.data.name)
        .customValidNotSunday(code: ErrorCodeKey.data.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.data.name);

    ruleFor((servico) => servico.descricao.value, key: ErrorCodeKey.descricao.name)
        .must((descricao) => descricao != "", "O campo 'descrição' é obrigatório!", ErrorCodeKey.descricao.name)
        .minLength(10, message: "É necessário o mínimo de 10 caracteres!", code: ErrorCodeKey.descricao.name)
        .must((descricao) => descricao.split(" ").length > 2, "Insira ao menos 3 palavras!", ErrorCodeKey.descricao.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.descricao.name);
  }
}
