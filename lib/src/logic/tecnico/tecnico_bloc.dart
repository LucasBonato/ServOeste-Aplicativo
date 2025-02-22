import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
import 'package:serv_oeste/src/repository/tecnico_repository.dart';

part 'tecnico_event.dart';

part 'tecnico_state.dart';

class TecnicoBloc extends Bloc<TecnicoEvent, TecnicoState> {
  final TecnicoRepository _tecnicoRepository = TecnicoRepository();
  String? _nome, _situacao;
  int? _id;

  TecnicoBloc() : super(TecnicoInitialState()) {
    on<TecnicoLoadingEvent>(_fetchAllTecnicos);
    on<TecnicoSearchOneEvent>(_fetchOneTecnico);
    on<TecnicoAvailabilitySearchEvent>(_fetchAvailability);
    on<TecnicoSearchEvent>(_searchTecnicos);
    on<TecnicoRegisterEvent>(_registerTecnico);
    on<TecnicoUpdateEvent>(_updateTecnico);
    on<TecnicoDisableListEvent>(_deleteListTecnicos);
  }

  Future<void> _fetchAllTecnicos(
      TecnicoLoadingEvent event, Emitter<TecnicoState> emit) async {
    emit(TecnicoLoadingState());
    try {
      final List<TecnicoResponse>? response =
          await _tecnicoRepository.getTecnicosByFind(
              id: event.id,
              nome: event.nome,
              situacao: event.situacao,
              equipamento: event.equipamento);
      emit(TecnicoSearchSuccessState(tecnicos: response ?? []));
    } on DioException catch (e) {
      emit(TecnicoErrorState(
        error:
            ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    } catch (e) {
      emit(TecnicoErrorState(
        error: ErrorEntity(id: 0, errorMessage: 'Erro ao buscar técnicos'),
      ));
    }
  }

  Future<void> _fetchOneTecnico(
      TecnicoSearchOneEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      Tecnico? tecnico = await _tecnicoRepository.getTecnicoById(event.id);
      if (tecnico != null) {
        emit(TecnicoSearchOneSuccessState(tecnico: tecnico));
        return;
      }
      emit(
        TecnicoErrorState(
          error: ErrorEntity(
            id: 0,
            errorMessage: "Não foi possível encontrar o técnico!",
          ),
        ),
      );
    } on DioException catch (e) {
      emit(TecnicoErrorState(error: e as ErrorEntity));
    }
  }

  Future<void> _fetchAvailability(
      TecnicoAvailabilitySearchEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      final List<TecnicoDisponivel>? tecnicosDisponiveis =
          await _tecnicoRepository
              .getTecnicosDisponiveis(event.idEspecialidade);
      emit(TecnicoSearchAvailabilitySuccessState(
          tecnicosDisponiveis: tecnicosDisponiveis ?? []));
    } on DioException catch (e) {
      emit(TecnicoErrorState(
        error:
            ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    }
  }

  Future<void> _searchTecnicos(
      TecnicoSearchEvent event, Emitter<TecnicoState> emit) async {
    _id = event.id;
    _nome = (event.nome?.isNotEmpty == true) ? event.nome : null;
    _situacao = (event.situacao?.isNotEmpty == true && event.situacao != null)
        ? event.situacao!.toLowerCase()
        : null;
    await _fetchAllTecnicos(
        TecnicoLoadingEvent(
            id: _id,
            nome: _nome,
            situacao: _situacao,
            equipamento: event.equipamento),
        emit);
  }

  Future<void> _registerTecnico(
      TecnicoRegisterEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      event.tecnico.sobrenome = event.sobrenome;
      ErrorEntity? error = await _tecnicoRepository.postTecnico(event.tecnico);
      emit((error == null)
          ? TecnicoRegisterSuccessState()
          : TecnicoErrorState(error: error));
    } on DioException catch (e) {
      emit(TecnicoErrorState(
          error: ErrorEntity(
              id: 0, errorMessage: e.message ?? "Erro desconhecido")));
    }
  }

  Future<void> _updateTecnico(TecnicoUpdateEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      event.tecnico.sobrenome = event.sobrenome;
      ErrorEntity? error = await _tecnicoRepository.putTecnico(event.tecnico);
      emit(error == null
          ? TecnicoUpdateSuccessState()
          : TecnicoErrorState(error: error));
    } catch (e) {
      emit(TecnicoErrorState(error: e as ErrorEntity));
    }
  }

  Future<void> _deleteListTecnicos(
      TecnicoDisableListEvent event, Emitter<TecnicoState> emit) async {
    emit(TecnicoLoadingState());
    try {
      await _tecnicoRepository.disableListOfTecnicos(event.selectedList);
      await _fetchAllTecnicos(
          TecnicoLoadingEvent(id: _id, nome: _nome, situacao: "ATIVO"), emit);
    } catch (e) {
      emit(TecnicoErrorState(
        error: ErrorEntity(id: 0, errorMessage: "Erro ao deletar técnicos"),
      ));
    }
  }
}
