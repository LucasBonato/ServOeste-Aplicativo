import 'package:flutter_test/flutter_test.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/features/servico/domain/validators/servico_validator.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/validation/validator.dart';

class _Validator with BackendErrorsValidator {}

void main() {
  test('aliases backend keys onto the form field keys', () {
    final validator = _Validator();
    validator.applyBackendError(ErrorEntity.fromJson({
      'detail': 'A validation error occurred',
      'error': {
        'nome': ['O Nome do cliente não pode ser vazio!'],
        'sobrenome': ['O Sobrenome do cliente precisa ter no mínimo 2 caracteres!'],
        'endereco': ['O Endereço é obrigatório!'],
        'telefoneCelular': ['Telefone celular inválido'],
      },
    }));

    expect(validator.externalErrors['nomeESobrenome'], contains('Nome'));
    expect(
      validator.externalErrors['nomeESobrenome'],
      contains('Sobrenome do cliente'),
    );
    expect(validator.externalErrors['rua'], 'O Endereço é obrigatório!');
    expect(validator.externalErrors['telefoneCelular'],
        'Telefone celular inválido');
    expect(validator.externalErrors.containsKey('nome'), isFalse);
    expect(validator.externalErrors.containsKey('sobrenome'), isFalse);
    expect(validator.externalErrors.containsKey('endereco'), isFalse);
  });

  test('idCliente maps onto the cliente field', () {
    final validator = _Validator();
    validator.applyBackendError(ErrorEntity.fromJson({
      'detail': 'A validation error occurred',
      'error': {
        'idCliente': ['O cliente é obrigatório'],
      },
    }));

    expect(validator.externalErrors['cliente'], 'O cliente é obrigatório');
    expect(validator.externalErrors.containsKey('idCliente'), isFalse);
    expect(validator.externalErrors.containsKey('global'), isFalse);
  });

  test('specific backend keys land on their fields', () {
    final validator = _Validator();
    validator.applyBackendError(ErrorEntity.fromJson({
      'detail': 'A validation error occurred',
      'error': {
        'dataPagamentoComissao': [
          'Data Pagamento Comissao é obrigatória para a situação Resolvido',
        ],
        'dataFechamento': [
          'Data fechamento é obrigatória para a situação Resolvido',
        ],
        'valorComissao': ['O Valor da Comissão é obrigatório.'],
        'valorPecas': ['O Valor das Peças é obrigatório.'],
        'formaPagamento': [
          'Forma de pagamento é obrigatória para a situação RESOLVIDO',
        ],
        'valor': ['O Valor é obrigatório.'],
        'situacao': [
          "Transição inválida de situação: 'Resolvido' para 'Garantia'",
        ],
        'cliente': ['Cliente não encontrado!'],
        'tecnico': ['Técnico não encontrado!'],
        'nomeSobrenome': ['O nome é obrigatório'],
      },
    }));

    expect(
      validator.externalErrors['dataPagamentoComissao'],
      contains('Pagamento Comissao'),
    );
    expect(
      validator.externalErrors['dataFechamento'],
      contains('Data fechamento'),
    );
    expect(
      validator.externalErrors['valorComissao'],
      contains('Valor da Comissão'),
    );
    expect(validator.externalErrors['valorPecas'], contains('Valor das Peças'));
    expect(
      validator.externalErrors['formaPagamento'],
      contains('Forma de pagamento'),
    );
    expect(validator.externalErrors['valor'], contains('Valor é obrigatório'));
    expect(
      validator.externalErrors['situacao'],
      contains('Transição inválida'),
    );
    expect(
      validator.externalErrors['cliente'],
      'Cliente não encontrado!',
    );
    expect(validator.externalErrors['tecnico'], 'Técnico não encontrado!');
    expect(
      validator.externalErrors['nomeESobrenome'],
      'O nome é obrigatório',
    );
  });

  test('servico validator requires client selection only in servico-only mode',
      () {
    final form = ServicoForm();
    final strict = ServicoValidator(servicoForm: form, requiresCliente: true);
    expect(strict.validate(form).errorsByKey['cliente'], isNotEmpty);

    final lenient = ServicoValidator(servicoForm: form);
    expect(lenient.validate(form).errorsByKey['cliente'], isNull);
  });

  test('unknown backend keys pass through unchanged', () {
    final validator = _Validator();
    validator.applyBackendError(ErrorEntity.fromJson({
      'detail': 'A validation error occurred',
      'error': {
        'marca': ['A marca é obrigatória'],
      },
    }));

    expect(validator.externalErrors['marca'], 'A marca é obrigatória');
  });
}
