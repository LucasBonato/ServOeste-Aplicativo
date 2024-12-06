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
        addListError(
            [ErrorCodeKey.telefoneFixo.name, ErrorCodeKey.telefoneCelular.name],
            errorEntity.errorMessage);
        break;
      case 5:
        addError(ErrorCodeKey.cep.name, errorEntity.errorMessage);
        break;
      case 6:
        addError(ErrorCodeKey.endereco.name, errorEntity.errorMessage);
        break;
      case 7:
        addError(ErrorCodeKey.rua.name, errorEntity.errorMessage);
        break;
      case 8:
        addError(ErrorCodeKey.numero.name, errorEntity.errorMessage);
        break;
      case 9:
        addError(ErrorCodeKey.municipio.name, errorEntity.errorMessage);
        break;
      case 10:
        addError(ErrorCodeKey.bairro.name, errorEntity.errorMessage);
        break;
      case 11:
        addError(ErrorCodeKey.cliente.name, errorEntity.errorMessage);
        break;
      case 12:
        addError(ErrorCodeKey.tecnico.name, errorEntity.errorMessage);
        break;
      case 13:
        addError(ErrorCodeKey.equipamento.name, errorEntity.errorMessage);
        break;
      case 14:
        addError(ErrorCodeKey.marca.name, errorEntity.errorMessage);
        break;
      case 15:
        addError(ErrorCodeKey.descricao.name, errorEntity.errorMessage);
        break;
      case 16:
        addError(ErrorCodeKey.filial.name, errorEntity.errorMessage);
        break;
      case 17:
        addError(ErrorCodeKey.horario.name, errorEntity.errorMessage);
        break;
      case 18:
        addError(ErrorCodeKey.data.name, errorEntity.errorMessage);
        break;
      case 19:
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

class ServicoValidator extends LucidValidator<ServicoForm>
    with BackendErrorsValidator {
  ServicoValidator() {
    ruleFor((servico) => servico.equipamento.value,
            key: ErrorCodeKey.equipamento.name)
        .must((equipamento) => equipamento != "", "Selecione um equipamento!",
            ErrorCodeKey.equipamento.name)
        .customValidExternalErrors(
            externalErrors, ErrorCodeKey.equipamento.name);

    ruleFor((servico) => servico.marca.value, key: ErrorCodeKey.marca.name)
        .must((marca) => marca != "", "Selecione a marca do equipamento!",
            ErrorCodeKey.marca.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.marca.name);

    ruleFor((servico) => servico.filial.value, key: ErrorCodeKey.filial.name)
        .must((filial) => filial != "", "Selecione uma filial!",
            ErrorCodeKey.filial.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.filial.name);

    ruleFor((servico) => servico.dataPrevista.value,
            key: ErrorCodeKey.data.name)
        .customValidNotSunday(code: ErrorCodeKey.data.name)
        .must((dataPrevista) => dataPrevista != "", "Selecione uma data!",
            ErrorCodeKey.data.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.data.name);

    ruleFor((servico) => servico.horario.value, key: ErrorCodeKey.horario.name)
        .must((horarioPrevisto) => horarioPrevisto != "",
            "Selecione um período válido!", ErrorCodeKey.horario.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.horario.name);

    ruleFor((servico) => servico.descricao.value,
            key: ErrorCodeKey.descricao.name)
        .must((descricao) => descricao != "",
            "O campo 'descrição' é obrigatório!", ErrorCodeKey.descricao.name)
        .minLength(10,
            message: "É necessário o mínimo de 10 caracteres!",
            code: ErrorCodeKey.descricao.name)
        .must((descricao) => descricao.split(" ").length > 2,
            "Insira ao menos 3 palavras!", ErrorCodeKey.descricao.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.descricao.name);

    ruleFor((servico) => servico.id, key: ErrorCodeKey.tecnico.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.tecnico.name)
        .must((id) => id != null, "Selecione um técnico",
            ErrorCodeKey.tecnico.name);
  }
}

class ClienteValidator extends LucidValidator<ClienteForm>
    with BackendErrorsValidator {
  ClienteValidator() {
    ruleFor((cliente) => cliente.nome.value,
            key: ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.isNotEmpty, "O campo 'nome' é obrigatório!",
            ErrorCodeKey.nomeESobrenome.name)
        .must(
            (nome) => nome.split(" ").length > 1,
            "É necessário o nome e sobrenome!",
            ErrorCodeKey.nomeESobrenome.name)
        .must(
            (nome) =>
                (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2),
            "O sobrenome precisa ter 2 caracteres!",
            ErrorCodeKey.nomeESobrenome.name)
        .customValidExternalErrors(
            externalErrors, ErrorCodeKey.nomeESobrenome.name);

    ruleFor((cliente) => cliente.telefoneCelular.value,
            key: ErrorCodeKey.telefoneCelular.name)
        .customValidExternalErrors(
            externalErrors, ErrorCodeKey.telefoneCelular.name);

    ruleFor((cliente) => cliente.telefoneFixo.value,
            key: ErrorCodeKey.telefoneFixo.name)
        .customValidExternalErrors(
            externalErrors, ErrorCodeKey.telefoneFixo.name);

    ruleFor((cliente) => cliente, key: ErrorCodeKey.telefones.name)
        .must(
            (cliente) =>
                cliente.telefoneCelular.value.isNotEmpty ||
                cliente.telefoneFixo.value.isNotEmpty,
            "Preencha ao menos um dos campos telefone!",
            ErrorCodeKey.telefones.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefones.name);

    ruleFor((cliente) => cliente.municipio.value,
            key: ErrorCodeKey.municipio.name)
        .must((cliente) => cliente.isNotEmpty, "Selecione um múnicipio.",
            ErrorCodeKey.municipio.name)
        .isNotNull()
        .customValidExternalErrors(externalErrors, ErrorCodeKey.municipio.name);

    ruleFor((cliente) => cliente.bairro.value, key: ErrorCodeKey.bairro.name)
        .must((municipio) => municipio.isNotEmpty,
            "O campo 'bairro' é obrigatório!", ErrorCodeKey.bairro.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.bairro.name);

    ruleFor((cliente) => cliente.rua.value, key: ErrorCodeKey.rua.name)
        .must((rua) => rua.isNotEmpty, "O campo 'rua' é obrigatório!",
            ErrorCodeKey.rua.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.rua.name);

    ruleFor((cliente) => cliente.numero.value, key: ErrorCodeKey.numero.name)
        .must((numero) => numero.isNotEmpty, "O campo 'número' é obrigatório!",
            ErrorCodeKey.numero.name)
        .must(
            (numero) => RegExp(r'^\d+$').hasMatch(numero),
            "O campo 'número' deve conter apenas dígitos!",
            ErrorCodeKey.numero.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.numero.name);
  }
}

class TecnicoValidator extends LucidValidator<TecnicoForm>
    with BackendErrorsValidator {
  List<int> conhecimentos = [];

  TecnicoValidator() {
    ruleFor((tecnico) => tecnico.nome.value,
            key: ErrorCodeKey.nomeESobrenome.name)
        .customValidExternalErrors(
            externalErrors, ErrorCodeKey.nomeESobrenome.name)
        .must((nome) => nome.isNotEmpty, "O campo 'nome' é obrigatório!",
            ErrorCodeKey.nomeESobrenome.name)
        .must(
            (nome) => nome.split(" ").length > 1,
            "É necessário o nome e sobrenome!",
            ErrorCodeKey.nomeESobrenome.name)
        .must(
            (nome) =>
                (nome.split(" ").length > 1 && nome.split(" ")[1].length > 2),
            "O sobrenome precisa ter 2 caracteres!",
            ErrorCodeKey.nomeESobrenome.name);

    ruleFor((tecnico) => tecnico.telefoneCelular.value,
            key: ErrorCodeKey.telefoneCelular.name)
        .customValidExternalErrors(
            externalErrors, ErrorCodeKey.telefoneCelular.name);

    ruleFor((tecnico) => tecnico.telefoneFixo.value,
            key: ErrorCodeKey.telefoneFixo.name)
        .customValidExternalErrors(
            externalErrors, ErrorCodeKey.telefoneFixo.name);

    ruleFor((cliente) => cliente, key: ErrorCodeKey.telefones.name)
        .must(
            (cliente) =>
                cliente.telefoneCelular.value.isNotEmpty ||
                cliente.telefoneFixo.value.isNotEmpty,
            "Preencha ao menos um dos campos telefone!",
            ErrorCodeKey.telefones.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.telefones.name);

    ruleFor((tecnico) => tecnico.conhecimentos.value,
            key: ErrorCodeKey.conhecimento.name)
        .customValidIsEmpty(
            conhecimentos,
            "Selecione ao menos um conhecimento!",
            ErrorCodeKey.conhecimento.name);
  }

  void setConhecimentos(List<int> conhecimentos) {
    this.conhecimentos.clear();
    this.conhecimentos.addAll(conhecimentos);
  }
}

extension CustomValidDateValidator on SimpleValidationBuilder<String> {
  SimpleValidationBuilder<String> customValidNotSunday(
      {String message = 'Datas aos domingos não são permitidas!',
      String code = 'invalid_sunday_date'}) {
    return must(
      (date) {
        try {
          final parts = date.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          final parsedDate = DateTime(year, month, day);
          return parsedDate.weekday != DateTime.sunday;
        } catch (e) {
          return false;
        }
      },
      message,
      code,
    );
  }
}

extension on LucidValidationBuilder<List<int>, TecnicoForm> {
  LucidValidationBuilder<List<int>, TecnicoForm> customValidIsEmpty(
      List<int> especialidades, String message, String code) {
    ValidationException? callback(value, entity) {
      if (especialidades.isNotEmpty) {
        return null;
      }
      return ValidationException(message: message, key: code, code: code);
    }

    return use(callback);
  }
}

extension on LucidValidationBuilder {
  LucidValidationBuilder customValidExternalErrors(
      Map<String, String> externalErrors, String code) {
    ValidationException? callback(value, entity) {
      if (externalErrors[code] == null) {
        return null;
      }
      return ValidationException(
          message: externalErrors[code]!, code: code, key: code);
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
  conhecimento,
  rua,
  numero,
  complemento
}
