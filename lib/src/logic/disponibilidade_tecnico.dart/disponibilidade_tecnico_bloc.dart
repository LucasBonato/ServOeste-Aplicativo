import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/disponibilidade_tecnico.dart/disponibilidade_tecnico_event.dart';
import 'package:serv_oeste/src/logic/disponibilidade_tecnico.dart/disponibilidade_tecnico_state.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/tecnico_repository.dart';

class DisponibilidadeBloc
    extends Bloc<DisponibilidadeEvent, DisponibilidadeState> {
  final TecnicoRepository _tecnicoRepository = TecnicoRepository();

  DisponibilidadeBloc() : super(DisponibilidadeInitialState()) {
    on<DisponibilidadesSearchEvent>(_fetchAllDisponibility);
  }

  Future<void> _fetchAllDisponibility(DisponibilidadesSearchEvent event,
      Emitter<DisponibilidadeState> emit) async {
    emit(DisponibilidadeLoadingState());
    try {
      final disponibilidades = await _tecnicoRepository
          .getTecnicosDisponiveis(event.especialidadeId);
      emit(DisponibilidadeSearchSuccessState(disponibilidades ?? []));
    } on DioException catch (e) {
      emit(DisponibilidadeErrorState(
        error:
            ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    }
  }
}
