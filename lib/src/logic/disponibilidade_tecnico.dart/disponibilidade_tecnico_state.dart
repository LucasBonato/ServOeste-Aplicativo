import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';

sealed class DisponibilidadeState {}

class DisponibilidadeInitialState extends DisponibilidadeState {}

class DisponibilidadeLoadingState extends DisponibilidadeState {}

class DisponibilidadeSearchSuccessState extends DisponibilidadeState {
  final List<TecnicoDisponivel> tecnicoDisponivel;

  DisponibilidadeSearchSuccessState(this.tecnicoDisponivel);
}

class DisponibilidadeErrorState extends DisponibilidadeState {
  final ErrorEntity error;

  DisponibilidadeErrorState({required this.error});
}
