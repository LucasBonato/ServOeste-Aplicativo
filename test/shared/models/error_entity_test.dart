import 'package:flutter_test/flutter_test.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

void main() {
  test('global error carries its real message in the errors map', () {
    final error = ErrorEntity.global('Sua sessão expirou. Faça login novamente.');

    expect(error.errors['global'], ['Sua sessão expirou. Faça login novamente.']);
    expect(error.detail, 'Sua sessão expirou. Faça login novamente.');
  });
}
