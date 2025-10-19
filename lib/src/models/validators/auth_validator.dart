import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/auth/auth_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';

class AuthValidator extends LucidValidator<AuthForm> with BackendErrorsValidator {
  AuthValidator() {
    ruleFor((auth) => auth.username.value, key: ErrorCodeKey.username.name)
        .must((username) => username.isNotEmpty, "Nome de usuário é obrigatório", ErrorCodeKey.username.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.username.name);

    ruleFor((auth) => auth.password.value, key: ErrorCodeKey.password.name)
        .must((password) => password.isNotEmpty, "Senha é obrigatória", ErrorCodeKey.password.name)
        .must((password) => password.length >= 4, "Senha deve ter pelo menos 4 caracteres", ErrorCodeKey.password.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.password.name);

    ruleFor((auth) => auth.role.value, key: ErrorCodeKey.role.name)
        .must((role) => role.isNotEmpty, "Cargo é obrigatório", ErrorCodeKey.role.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.role.name);
  }
}
