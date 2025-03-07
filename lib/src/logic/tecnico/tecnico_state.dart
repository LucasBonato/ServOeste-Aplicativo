part of 'tecnico_bloc.dart';

@immutable
sealed class TecnicoState {}

final class TecnicoInitialState extends TecnicoState {}

final class TecnicoLoadingState extends TecnicoState {}

final class TecnicoSearchOneSuccessState extends TecnicoState {
  final Tecnico tecnico;

  TecnicoSearchOneSuccessState({required this.tecnico});
}

final class TecnicoSearchAvailabilitySuccessState extends TecnicoState {
  final List<TecnicoDisponivel>? tecnicosDisponiveis;

  TecnicoSearchAvailabilitySuccessState({
    this.tecnicosDisponiveis
  });
}

final class TecnicoSearchSuccessState extends TecnicoState {
  final List<TecnicoResponse> tecnicos;

  TecnicoSearchSuccessState({required this.tecnicos});
}

final class TecnicoRegisterSuccessState extends TecnicoState {}

final class TecnicoUpdateSuccessState extends TecnicoState {}

final class TecnicoErrorState extends TecnicoState {
  final ErrorEntity error;

  TecnicoErrorState({required this.error});
}
