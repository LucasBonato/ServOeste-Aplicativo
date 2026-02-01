import 'package:serv_oeste/features/servico/domain/entities/servico_filter_form.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';

class ServicoFilterFormArgs {
  final ServicoBloc bloc;
  final String title;
  final String submitText;
  final ServicoFilterForm form;

  const ServicoFilterFormArgs({
    required this.bloc,
    required this.title,
    required this.submitText,
    required this.form,
  });
}
