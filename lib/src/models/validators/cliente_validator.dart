import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';

class ClienteValidator extends LucidValidator<ClienteForm> with BackendErrorsValidator {
  ClienteValidator() {
    ruleFor((cliente) => cliente.nome.value, key: ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.isNotEmpty, "O campo 'nome' é obrigatório!", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => (nome.trim().split(" ").length > 1 && nome.trim().split(" ")[1].length >= 2), "O sobrenome precisa ter 2 caracteres!", ErrorCodeKey.nomeESobrenome.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.nomeESobrenome.name);

    ruleFor((cliente) => cliente.telefoneCelular.value, key: ErrorCodeKey.telefoneCelular.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneCelular.name);

    ruleFor((cliente) => cliente.telefoneFixo.value, key: ErrorCodeKey.telefoneFixo.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneFixo.name);

    ruleFor((cliente) => cliente, key: ErrorCodeKey.telefones.name)
        .must((cliente) => cliente.telefoneCelular.value.isNotEmpty || cliente.telefoneFixo.value.isNotEmpty, "Preencha ao menos um dos campos telefone!",
            ErrorCodeKey.telefones.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefones.name);

    ruleFor((cliente) => cliente.municipio.value, key: ErrorCodeKey.municipio.name)
        .must((cliente) => cliente.isNotEmpty, "Selecione um múnicipio.", ErrorCodeKey.municipio.name)
        .isNotNull()
        .customValidExternalErrors(externalErrors, ErrorCodeKey.municipio.name);

    ruleFor((cliente) => cliente.bairro.value, key: ErrorCodeKey.bairro.name)
        .must((municipio) => municipio.isNotEmpty, "O campo 'bairro' é obrigatório!", ErrorCodeKey.bairro.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.bairro.name);

    ruleFor((cliente) => cliente.rua.value, key: ErrorCodeKey.rua.name)
        .must((rua) => rua.isNotEmpty, "O campo 'rua' é obrigatório!", ErrorCodeKey.rua.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.rua.name);

    ruleFor((cliente) => cliente.numero.value, key: ErrorCodeKey.numero.name)
        .must((numero) => numero.isNotEmpty, "O campo 'número' é obrigatório!", ErrorCodeKey.numero.name)
        .must((numero) => RegExp(r'^\d+$').hasMatch(numero), "O campo 'número' deve conter apenas dígitos!", ErrorCodeKey.numero.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.numero.name);
  }
}
