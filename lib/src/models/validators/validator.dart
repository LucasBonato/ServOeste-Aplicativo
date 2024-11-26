import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';

mixin BackendErrorsValidator {
  final Map<String, String> externalErrors = {};

  void applyBackendError(ErrorEntity errorEntity) {
    switch (errorEntity.id) {
      case 1:
        addError(ErrorCodeKey.nomeESobrenome.name, errorEntity.errorMessage);
        break;
      case 2:
        addError(ErrorCodeKey.telefoneCelular.name, errorEntity.errorMessage);
        break;
      case 3:
        addError(ErrorCodeKey.telefoneFixo.name, errorEntity.errorMessage);
        break;
      case 4:
        addListError([ErrorCodeKey.telefoneFixo.name, ErrorCodeKey.telefoneCelular.name], errorEntity.errorMessage);
        break;
      case 5:
        addError(ErrorCodeKey.cep.name, errorEntity.errorMessage);
        break;
      case 6:
        addError(ErrorCodeKey.endereco.name, errorEntity.errorMessage);
        break;
      case 7:
        addError(ErrorCodeKey.municipio.name, errorEntity.errorMessage);
        break;
      case 8:
        addError(ErrorCodeKey.bairro.name, errorEntity.errorMessage);
        break;
      case 9:
        addError(ErrorCodeKey.cliente.name, errorEntity.errorMessage);
        break;
      case 10:
        addError(ErrorCodeKey.tecnico.name, errorEntity.errorMessage);
        break;
      case 11:
        addError(ErrorCodeKey.equipamento.name, errorEntity.errorMessage);
        break;
      case 12:
        addError(ErrorCodeKey.marca.name, errorEntity.errorMessage);
        break;
      case 13:
        addError(ErrorCodeKey.descricao.name, errorEntity.errorMessage);
        break;
      case 14:
        addError(ErrorCodeKey.filial.name, errorEntity.errorMessage);
        break;
      case 15:
        addError(ErrorCodeKey.horario.name, errorEntity.errorMessage);
        break;
      case 16:
        addError(ErrorCodeKey.data.name, errorEntity.errorMessage);
        break;
      case 17:
        addError(ErrorCodeKey.conhecimento.name, errorEntity.errorMessage);
        break;
      default:
        addError(ErrorCodeKey.global.name, errorEntity.errorMessage);
    }
  }

  void cleanExternalErrors() {
    externalErrors.clear();
  }

  void addError(String key, String message) {
    externalErrors[key] = message;
  }

  void addListError(List<String> keys, String message) {
    for (String key in keys) {
      externalErrors[key] = message;
    }
  }
}

class ServicoValidator extends LucidValidator<ServicoForm> with BackendErrorsValidator {
  ServicoValidator() {
    ruleFor((servico) => servico.equipamento.value, key: ErrorCodeKey.equipamento.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.equipamento.name)
        .isNotNull();

    ruleFor((servico) => servico.marca.value, key: ErrorCodeKey.marca.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.marca.name)
        .isNotNull();

    ruleFor((servico) => servico.filial.value, key: ErrorCodeKey.filial.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.filial.name)
        .isNotNull();

    ruleFor((servico) => servico.dataAtendimentoPrevisto.value, key: ErrorCodeKey.data.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.data.name)
        .isNotNull();

    ruleFor((servico) => servico.horarioPrevisto.value, key: ErrorCodeKey.horario.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.horario.name)
        .isNotNull();

    ruleFor((servico) => servico.descricao.value, key: ErrorCodeKey.descricao.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.descricao.name)
        .isNotNull();

    ruleFor((servico) => servico.nomeTecnico.value, key: ErrorCodeKey.tecnico.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.tecnico.name)
        .isNotNull();

    ruleFor((servico) => servico.idTecnico.value, key: ErrorCodeKey.tecnico.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.tecnico.name)
        .isNotNull();
  }
}

class ClienteValidator extends LucidValidator<ClienteForm> with BackendErrorsValidator {
  ClienteValidator() {
    ruleFor((cliente) => cliente.nome.value, key: ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.isNotEmpty, "O nome é obrigatório!.", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2), "O sobrenome precisa ter 2 caracteres!", ErrorCodeKey.nomeESobrenome.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.nomeESobrenome.name);

    ruleFor((cliente) => cliente.telefoneCelular.value, key: ErrorCodeKey.telefoneCelular.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneCelular.name);

    ruleFor((cliente) => cliente.telefoneFixo.value, key: ErrorCodeKey.telefoneFixo.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneFixo.name);

    ruleFor((cliente) => cliente.endereco.value, key: ErrorCodeKey.endereco.name)
        .mustHaveNumber()
        .customValidExternalErrors(externalErrors, ErrorCodeKey.endereco.name);

    ruleFor((cliente) => cliente.municipio.value, key: ErrorCodeKey.municipio.name)
        .must((cliente) => cliente.isNotEmpty, "Selecione um múnicipio", ErrorCodeKey.municipio.name)
        .isNotNull()
        .customValidExternalErrors(externalErrors, ErrorCodeKey.municipio.name);

    ruleFor((cliente) => cliente.bairro.value, key: ErrorCodeKey.bairro.name)
        .must((municipio) => municipio.isNotEmpty, "'bairro' cannot be empty", ErrorCodeKey.bairro.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.nomeESobrenome.name);
  }
}

class TecnicoValidator extends LucidValidator<TecnicoForm> with BackendErrorsValidator {
  List<int> conhecimentos = [];

  TecnicoValidator() {
    ruleFor((tecnico) => tecnico.nome.value, key: ErrorCodeKey.nomeESobrenome.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.isNotEmpty, "O nome é obrigatório!.", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.split(" ").length > 1, "É necessário o nome e sobrenome!", ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2), "O sobrenome precisa ter 2 caracteres!", ErrorCodeKey.nomeESobrenome.name);

    ruleFor((tecnico) => tecnico.telefoneCelular.value, key: ErrorCodeKey.telefoneCelular.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneCelular.name);

    ruleFor((tecnico) => tecnico.telefoneFixo.value, key: ErrorCodeKey.telefoneFixo.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefoneFixo.name);

    ruleFor((tecnico) => tecnico.conhecimentos.value, key: ErrorCodeKey.conhecimento.name)
        .customValidIsEmpty(conhecimentos, "Selecione ao menos um conhecimento!", ErrorCodeKey.conhecimento.name);
  }

  void setConhecimentos(List<int> conhecimentos) {
    this.conhecimentos.clear();
    this.conhecimentos.addAll(conhecimentos);
  }
}

extension on LucidValidationBuilder<List<int>, TecnicoForm> {
  LucidValidationBuilder<List<int>, TecnicoForm> customValidIsEmpty(List<int> especialidades, String message, String code) {
    ValidationException? callback(value, entity) {
      if(especialidades.isNotEmpty) {
        return null;
      }
      return ValidationException(
          message: message,
          key: code,
          code: code
      );
    }

    return use(callback);
  }
}

extension on LucidValidationBuilder {
  LucidValidationBuilder customValidExternalErrors(Map<String, String> externalErrors, String code) {
    ValidationException? callback(value, entity) {
      if(externalErrors[code] == null) {
        return null;
      }
      return ValidationException(
          message: externalErrors[code]!,
          code: code
      );
    }

    return use(callback);
  }
}

enum ErrorCodeKey {
  global,
  nomeESobrenome,
  telefoneCelular,
  telefoneFixo,
  telefones,
  cep,
  endereco,
  municipio,
  bairro,
  cliente,
  tecnico,
  equipamento,
  marca,
  descricao,
  filial,
  horario,
  data,
  conhecimento
}