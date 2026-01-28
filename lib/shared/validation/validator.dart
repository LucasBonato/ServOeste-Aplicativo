import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_form.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

mixin BackendErrorsValidator {
  final Map<String, String> externalErrors = {};

  void applyBackendError(ErrorEntity errorEntity) {
    externalErrors.clear();

    for (final entry in errorEntity.errors.entries) {
      final key = entry.key;
      final messages = entry.value;

      if (messages.isEmpty) continue;

      final message = messages.join("\n");

      addError(key, message);
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
  SimpleValidationBuilder<String> customValidNotSunday({String message = 'Datas aos domingos não são permitidas!', String code = 'invalid_sunday_date'}) {
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
  LucidValidationBuilder<List<int>, TecnicoForm> customValidIsEmpty(List<int> especialidades, String message, String code) {
    ValidationException? callback(value, entity) {
      if (especialidades.isNotEmpty) {
        return null;
      }
      return ValidationException(message: message, key: code, code: code, entity: code);
    }

    return use(callback);
  }
}

extension CustomValidExternalError on LucidValidationBuilder {
  LucidValidationBuilder customValidExternalErrors(Map<String, String> externalErrors, String code) {
    ValidationException? callback(value, entity) {
      if (externalErrors[code] == null) {
        return null;
      }
      return ValidationException(message: externalErrors[code]!, code: code, key: code, entity: code);
    }

    return use(callback);
  }
}
