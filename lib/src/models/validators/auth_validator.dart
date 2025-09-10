import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/auth/auth_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';

class AuthValidator extends LucidValidator<AuthForm>
    with BackendErrorsValidator {
  AuthValidator() {
    ruleFor((auth) => auth.username.value, key: ErrorCodeKey.user.name)
        .must((username) => username.isNotEmpty,
            "Nome de usuário é obrigatório", ErrorCodeKey.user.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.user.name);

    ruleFor((auth) => auth.password.value, key: ErrorCodeKey.user.name)
        .must((password) => password.isNotEmpty, "Senha é obrigatória",
            ErrorCodeKey.user.name)
        .must((password) => password.length >= 4,
            "Senha deve ter pelo menos 4 caracteres", ErrorCodeKey.user.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.user.name);

    ruleFor((auth) => auth.role.value, key: ErrorCodeKey.user.name)
        .must((role) => role.isNotEmpty, "Cargo é obrigatório",
            ErrorCodeKey.user.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.user.name);
  }
}
