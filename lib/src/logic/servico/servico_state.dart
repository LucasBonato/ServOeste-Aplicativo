import 'package:serv_oeste/src/models/servico/servico.dart';
import '../../models/error/error_entity.dart';

sealed class ServicoState {}

final class ServicoInitialState extends ServicoState {}

final class ServicoLoadingState extends ServicoState {}

final class ServicoSearchOneSuccessState extends ServicoState {
  final Servico servico;

  ServicoSearchOneSuccessState({required this.servico});
}

final class ServicoSearchSuccessState extends ServicoState {
  final List<Servico> servicos;

  ServicoSearchSuccessState({required this.servicos});
}

final class ServicoRegisterSuccessState extends ServicoState {}

final class ServicoUpdateSuccessState extends ServicoState {}

final class ServicoDeleteSuccessState extends ServicoState {}

final class ServicoErrorState extends ServicoState {
  final ErrorEntity error;

  ServicoErrorState({required this.error});
}
