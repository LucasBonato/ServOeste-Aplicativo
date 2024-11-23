import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/repository/tecnico_repository.dart';

part 'tecnico_event.dart';
part 'tecnico_state.dart';

class TecnicoBloc extends Bloc<TecnicoEvent, TecnicoState> {
  final TecnicoRepository _tecnicoRepository = TecnicoRepository();
  String? _nome, _situacao, _telefoneFixo, _telefoneCelular;
  int? _id;

  TecnicoBloc() : super(TecnicoInitialState()) {
    on<TecnicoLoadingEvent>(_fetchAllTecnicos);
    on<TecnicoSearchOneEvent>(_fetchOneTecnico);
    on<TecnicoSearchEvent>(_searchTecnicos);
    on<TecnicoRegisterEvent>(_registerTecnico);
    on<TecnicoUpdateEvent>(_updateTecnico);
    on<TecnicoDisableListEvent>(_disableListOfTecnicos);
  }

  Future<void> _fetchAllTecnicos(
      TecnicoLoadingEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      final List<Tecnico>? tecnicos =
          await _tecnicoRepository.getTecnicosByFind(
              id: event.id,
              nome: event.nome,
              telefoneFixo: event.telefoneFixo,
              telefoneCelular: event.telefoneCelular,
              situacao: event.situacao);
      emit(TecnicoSearchSuccessState(tecnicos: tecnicos ?? []));
    } on DioException catch (e) {
      emit(TecnicoErrorState(
          error: ErrorEntity(
              id: 0, errorMessage: e.message ?? "Erro desconhecido")));
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
      emit(TecnicoErrorState(
          error: ErrorEntity(
              id: 0, errorMessage: "Não foi possível encontrar o técnico!")));
    } on DioException catch (e) {
      emit(TecnicoErrorState(
          error: ErrorEntity(
              id: 0, errorMessage: e.message ?? "Erro desconhecido")));
    }
  }

  Future<void> _searchTecnicos(TecnicoSearchEvent event, Emitter emit) async {
    _id = event.id;
    _nome = event.nome?.isNotEmpty == true ? event.nome : null;
    _situacao = event.situacao?.isNotEmpty == true && event.situacao != null
        ? event.situacao!.toLowerCase()
        : null;

    await _fetchAllTecnicos(
        TecnicoLoadingEvent(id: _id, nome: _nome, situacao: _situacao), emit);
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
      emit(TecnicoErrorState(
          error:
              ErrorEntity(id: 0, errorMessage: "Erro ao atualizar o técnico")));
    }
  }

  Future<void> _disableListOfTecnicos(
      TecnicoDisableListEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      await _tecnicoRepository.disableListOfTecnicos(event.selectedList);
      await _fetchAllTecnicos(
          TecnicoLoadingEvent(id: _id, nome: _nome, situacao: _situacao), emit);
    } catch (e) {
      emit(TecnicoErrorState(
          error:
              ErrorEntity(id: 0, errorMessage: "Erro ao desativar técnicos")));
    }
  }
}
