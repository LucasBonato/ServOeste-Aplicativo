part of 'servico_bloc.dart';

@immutable
sealed class ServicoState {}

final class ServicoInitialState extends ServicoState {}

final class ServicoLoadingState extends ServicoState {}

final class ServicoSearchOneLoadingState extends ServicoState {}

final class ServicoSearchOneSuccessState extends ServicoState {
  final Servico servico;

  ServicoSearchOneSuccessState({required this.servico});
}

final class ServicoSearchSuccessState extends ServicoState {
  final List<Servico> servicos;
  final ServicoFilter filter;
  final int totalElements;
  final int currentPage;
  final int totalPages;

  ServicoSearchSuccessState({
    required this.servicos,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.filter,
  });
}

final class ServicoRegisterSuccessState extends ServicoState {}

final class ServicoUpdateSuccessState extends ServicoState {}

final class ServicoDeleteSuccessState extends ServicoState {}

final class ServicoErrorState extends ServicoState {
  final ErrorEntity error;

  ServicoErrorState({required this.error});
}
