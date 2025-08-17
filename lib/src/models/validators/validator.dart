import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

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
        addError(ErrorCodeKey.rua.name, errorEntity.errorMessage);
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
      case 18:
        addError(ErrorCodeKey.servico.name, errorEntity.errorMessage);
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

extension CustomValidDateValidator on SimpleValidationBuilder<String> {
  SimpleValidationBuilder<String> customValidNotSunday(
      {String message = 'Datas aos domingos não são permitidas!',
      String code = 'invalid_sunday_date'}) {
    return must(
      (date) {
        if (date.trim().isEmpty) return true;

        try {
          final parts = date.split('/');
          if (parts.length < 3) return false;

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

extension CustomValidIsEmpty on LucidValidationBuilder<List<int>, TecnicoForm> {
  LucidValidationBuilder<List<int>, TecnicoForm> customValidIsEmpty(
      List<int> especialidades, String message, String code) {
    ValidationException? callback(value, entity) {
      if (especialidades.isNotEmpty) {
        return null;
      }
      return ValidationException(
          message: message, key: code, code: code, entity: code);
    }

    return use(callback);
  }
}

extension CustomValidExternalError on LucidValidationBuilder {
  LucidValidationBuilder customValidExternalErrors(
      Map<String, String> externalErrors, String code) {
    ValidationException? callback(value, entity) {
      if (externalErrors[code] == null) {
        return null;
      }
      return ValidationException(
          message: externalErrors[code]!, code: code, key: code, entity: code);
    }

    return use(callback);
  }
}
