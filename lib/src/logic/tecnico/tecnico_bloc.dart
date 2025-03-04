import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
import 'package:serv_oeste/src/repository/tecnico_repository.dart';
import 'package:serv_oeste/src/shared/constants.dart';

part 'tecnico_event.dart';
part 'tecnico_state.dart';

class TecnicoBloc extends BaseEntityBloc<TecnicoEvent, TecnicoState> {
  final TecnicoRepository _tecnicoRepository = TecnicoRepository();
  bool isFirstRequest = true;
  String? _nome, _situacao, nomeMenu, situacaoMenu;
  int? _id, idMenu;

  @override
  TecnicoState loadingState() => TecnicoLoadingState();

  @override
  TecnicoState errorState(ErrorEntity error) => TecnicoErrorState(error: error);

  TecnicoBloc() : super(TecnicoInitialState()) {
    on<TecnicoLoadingEvent>(_fetchAllTecnicos);
    on<TecnicoSearchOneEvent>(_fetchOneTecnico);
    on<TecnicoAvailabilitySearchEvent>(_fetchAvailability);
    on<TecnicoSearchEvent>(_searchTecnicos);
    on<TecnicoSearchMenuEvent>(_searchMenuTecnicos);
    on<TecnicoRegisterEvent>(_registerTecnico);
    on<TecnicoUpdateEvent>(_updateTecnico);
    on<TecnicoDisableListEvent>(_deleteListTecnicos);
  }

  Future<void> _fetchAllTecnicos(TecnicoLoadingEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest<List<TecnicoResponse>>(
      emit: emit,
      request: () => _tecnicoRepository.fetchListByFilter(
        id: event.id,
        nome: event.nome,
        situacao: event.situacao,
        equipamento: event.equipamento
      ),
      onSuccess: (List<TecnicoResponse> tecnicos) => emit(TecnicoSearchSuccessState(tecnicos: tecnicos)),
    );
  }

  Future<void> _fetchOneTecnico(TecnicoSearchOneEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest<Tecnico?>(
      emit: emit,
      request: () => _tecnicoRepository.fetchOneById(event.id),
      onSuccess: (Tecnico? tecnico) {
        if (tecnico != null) {
          emit(TecnicoSearchOneSuccessState(tecnico: tecnico));
        }
      }
    );
  }

  Future<void> _fetchAvailability(TecnicoAvailabilitySearchEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest<List<TecnicoDisponivel>>(
      emit: emit,
      request: () => _tecnicoRepository.fetchListAvailabilityBySpecialityId(event.idEspecialidade),
      onSuccess: (List<TecnicoDisponivel> tecnicosDisponiveis) => emit(TecnicoSearchAvailabilitySuccessState(tecnicosDisponiveis: tecnicosDisponiveis)),
    );
  }

  Future<void> _searchTecnicos(TecnicoSearchEvent event, Emitter<TecnicoState> emit) async {
    _id = event.id;
    _nome = (event.nome?.isNotEmpty == true) ? event.nome : null;
    _situacao = (event.situacao?.isNotEmpty == true && event.situacao != null) ? event.situacao!.toLowerCase() : null;
    add(TecnicoLoadingEvent(id: _id, nome: _nome, situacao: _situacao, equipamento: event.equipamento));
  }

  Future<void> _searchMenuTecnicos(TecnicoSearchMenuEvent event, Emitter<TecnicoState> emit) async {
    idMenu = event.id?? idMenu;
    nomeMenu = event.nome?? nomeMenu;
    situacaoMenu = (event.situacao?.isNotEmpty == true && event.situacao != null) ? event.situacao!.toLowerCase() : situacaoMenu;
    situacaoMenu = (isFirstRequest) ? Constants.situationTecnicoList.first.toLowerCase() : situacaoMenu;
    isFirstRequest = false;
    add(TecnicoLoadingEvent(id: idMenu, nome: nomeMenu, situacao: situacaoMenu, equipamento: event.equipamento));
  }

  Future<void> _registerTecnico(TecnicoRegisterEvent event, Emitter<TecnicoState> emit) async {
    event.tecnico.sobrenome = event.sobrenome;
    await handleRequest(
      emit: emit,
      request: () => _tecnicoRepository.create(event.tecnico),
      onSuccess: (_) => emit(TecnicoRegisterSuccessState())
    );
  }

  Future<void> _updateTecnico(TecnicoUpdateEvent event, Emitter<TecnicoState> emit) async {
    event.tecnico.sobrenome = event.sobrenome;
    await handleRequest(
      emit: emit,
      request: () => _tecnicoRepository.update(event.tecnico),
      onSuccess: (_) => emit(TecnicoUpdateSuccessState())
    );
  }

  Future<void> _deleteListTecnicos(TecnicoDisableListEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _tecnicoRepository.disableListByIds(event.selectedList),
      onSuccess: (_) => add(TecnicoLoadingEvent(id: _id, nome: _nome)),
    );
  }
}
