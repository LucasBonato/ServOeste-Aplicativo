import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/features/auth/domain/entities/auth_form.dart';
import 'package:serv_oeste/shared/models/enums/error_code_key.dart';
import 'package:serv_oeste/shared/validation/validator.dart';

class AuthValidator extends LucidValidator<AuthForm> with BackendErrorsValidator {
  AuthValidator() {
    ruleFor((auth) => auth.username.value, key: ErrorCodeKey.username.name)
        .must((username) => username.isNotEmpty, "Nome de usuário é obrigatório", ErrorCodeKey.username.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.username.name);

    ruleFor((auth) => auth.password.value, key: ErrorCodeKey.password.name)
        .must((password) => password.isNotEmpty, "Senha é obrigatória", ErrorCodeKey.password.name)
        .must((password) => password.length >= 4, "Senha deve ter pelo menos 4 caracteres", ErrorCodeKey.password.name)
        .customValidExternalErrors(externalErrors, ErrorCodeKey.password.name);
  }
}
