import 'package:flutter_test/flutter_test.dart';
import 'package:serv_oeste/features/servico/domain/entities/enums/service_periodo.dart';
import 'package:serv_oeste/features/servico/domain/entities/enums/service_status.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/features/servico/domain/rules/service_field_rules.dart';
import 'package:serv_oeste/shared/models/enums/error_code_key.dart';

void main() {
  test('service enums use explicit API values and reject unknown values', () {
    expect(
      ServiceStatus.fromJson('AGUARDANDO_AGENDAMENTO'),
      ServiceStatus.aguardandoAgendamento,
    );
    expect(ServiceStatus.garantia.toJson(), 'GARANTIA');
    expect(ServicePeriodo.fromJson('TARDE'), ServicePeriodo.tarde);
    expect(() => ServiceStatus.fromJson('UNSUPPORTED'), throwsFormatException);
  });

  test(
    'warranty end defaults to three months and recalculates on start change',
    () {
      final form = ServicoForm();
      form.setDataInicioGarantia('31/01/2025');
      expect(form.dataFinalGarantia.value, '30/04/2025');

      form.setDataInicioGarantia('30/11/2024');
      expect(form.dataFinalGarantia.value, '28/02/2025');
    },
  );

  test('explicit warranty end date is retained when start date changes', () {
    final form = ServicoForm();
    form.setDataFinalGarantia('15/06/2025');
    form.setDataInicioGarantia('01/01/2025');
    expect(form.dataFinalGarantia.value, '15/06/2025');
  });

  test('form stores status and period as enums', () {
    final form = ServicoForm();
    form.setSituacao(ServiceStatus.garantia);
    form.setHorario('Tarde');

    expect(form.situacao.value, ServiceStatus.garantia);
    expect(form.periodo.value, ServicePeriodo.tarde);
    expect(form.situacaoLabel.value, 'Garantia');
    expect(form.periodoLabel.value, 'Tarde');
  });

  test('warranty closing date may be required and disabled independently', () {
    expect(
      ServiceFieldRules.isRequired(
        ErrorCodeKey.dataFechamento,
        ServiceStatus.garantia,
      ),
      isTrue,
    );
    // GARANTIA is not in the committed disabled list for dataFechamento.
    expect(
      ServiceFieldRules.isDisabled(
        ErrorCodeKey.dataFechamento,
        ServiceStatus.garantia,
      ),
      isFalse,
    );
  });
}
