part of 'servico_bloc.dart';

@immutable
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

final class ServicoUpdateSuccessState extends ServicoState {
  final Servico servico;

  ServicoUpdateSuccessState({required this.servico});
}

final class ServicoDeleteSuccessState extends ServicoState {}

final class ServicoErrorState extends ServicoState {
  final ErrorEntity error;

  ServicoErrorState({required this.error});
}
