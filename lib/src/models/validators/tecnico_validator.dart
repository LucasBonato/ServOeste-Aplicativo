
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';

class TecnicoValidator extends LucidValidator<TecnicoForm> with BackendErrorsValidator {
  List<int> conhecimentos = [];
  final bool isUpdate;

  TecnicoValidator({this.isUpdate = false}) {
    ruleFor((tecnico) => tecnico.nome.value, key: ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.isNotEmpty, "O campo 'nome' é obrigatório!", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => (nome.trim().split(" ").length > 1 && nome.trim().split(" ")[1].length >= 2), "O sobrenome precisa ter 2 caracteres!", ErrorCodeKey.nomeESobrenome.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.nomeESobrenome.name);

    ruleFor((tecnico) => tecnico.situacao.value, key: ErrorCodeKey.situacao.name)
        .must((situacao) => ((isUpdate) ? situacao.isNotEmpty : true), "Selecione uma situação.", ErrorCodeKey.situacao.name);

    ruleFor((tecnico) => tecnico.telefoneCelular.value, key: ErrorCodeKey.telefoneCelular.name)
        .must((celular) => ((celular.isNotEmpty && celular.length < 15) ? false : true), "Tamanho inválido do telefone celular!", ErrorCodeKey.telefoneCelular.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneCelular.name);

    ruleFor((tecnico) => tecnico.telefoneFixo.value, key: ErrorCodeKey.telefoneFixo.name)
        .must((fixo) => ((fixo.isNotEmpty && fixo.length < 14) ? false : true), "Tamanho inválido do telefone fixo!", ErrorCodeKey.telefoneFixo.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneFixo.name);

    ruleFor((cliente) => cliente, key: ErrorCodeKey.telefones.name)
        .must((cliente) => cliente.telefoneCelular.value.isNotEmpty || cliente.telefoneFixo.value.isNotEmpty, "Preencha ao menos um dos campos telefone!",
        ErrorCodeKey.telefones.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefones.name);

    ruleFor((tecnico) => tecnico.conhecimentos.value, key: ErrorCodeKey.conhecimento.name)
        .customValidIsEmpty(conhecimentos, "Selecione ao menos um conhecimento!", ErrorCodeKey.conhecimento.name);
  }

  void setConhecimentos(List<int> conhecimentos) {
    this.conhecimentos.clear();
    this.conhecimentos.addAll(conhecimentos);
  }
}
