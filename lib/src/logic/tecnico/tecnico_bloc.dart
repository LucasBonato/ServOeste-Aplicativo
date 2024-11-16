import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/repository/tecnico_repository.dart';

part 'tecnico_event.dart';
part 'tecnico_state.dart';

class TecnicoBloc extends Bloc<TecnicoEvent, TecnicoState> {
  final TecnicoRepository _tecnicoRepository = TecnicoRepository();
  String? _nome, _situacao;
  int? _id;

  TecnicoBloc() : super(TecnicoInitialState()) {
    on<TecnicoLoadingEvent>(_fetchAllTecnicos);
    on<TecnicoSearchEvent>(_searchTecnicos);
    on<TecnicoRegisterEvent>(_registerTecnico);
  }

  Future<void> _fetchAllTecnicos(TecnicoLoadingEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      final List<Tecnico>? tecnicos = await _tecnicoRepository.getTecnicosByFind(
        id: event.id,
        nome: event.nome,
        situacao: event.situacao
      );
      emit(TecnicoSearchSuccessState(tecnicos: tecnicos?? []));
    } on DioException catch (e) {
      emit(TecnicoErrorState(error: ErrorEntity(id: 0, errorMessage: e.message?? "")));
    }
  }
  
  Future<void> _searchTecnicos(TecnicoSearchEvent event, Emitter emit) async {
    _id = event.id;
    _nome = event.nome?.isNotEmpty == true ? event.nome : null;
    _situacao = event.situacao?.isNotEmpty == true && event.situacao != null ? event.situacao!.toLowerCase() : null;
    await _fetchAllTecnicos(TecnicoLoadingEvent(id: _id, nome: _nome, situacao: _situacao), emit);
  }

  Future<void> _registerTecnico(TecnicoRegisterEvent event, Emitter emit) async {
    emit(TecnicoLoadingState());
    try {
      event.tecnico.sobrenome = event.sobrenome;
      ErrorEntity? error = await _tecnicoRepository.postTecnico(event.tecnico);
      emit((error == null) ? TecnicoRegisterSuccessState() : TecnicoErrorState(error: error));
    } on DioException {
      emit(ClienteErrorState(error: ErrorEntity(id: 0, errorMessage: "Algo não ocorreu como esperado")));
    }
  }
}
