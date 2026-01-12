import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/clients/tecnico_client.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';

part 'tecnico_event.dart';
part 'tecnico_state.dart';

class TecnicoBloc extends BaseEntityBloc<TecnicoEvent, TecnicoState> {
  final TecnicoClient _tecnicoClient;
  bool isFirstRequest = true;

  int? idMenu;
  String? nomeMenu;
  String? situacaoMenu;

  @override
  TecnicoState loadingState() => TecnicoLoadingState();

  @override
  TecnicoState errorState(ErrorEntity error) => TecnicoErrorState(error: error);

  TecnicoBloc(this._tecnicoClient) : super(TecnicoInitialState()) {
    on<TecnicoLoadingEvent>(_fetchAllTecnicos);
    on<TecnicoSearchOneEvent>(_fetchOneTecnico);
    on<TecnicoAvailabilitySearchEvent>(_fetchAvailability);
    on<TecnicoSearchEvent>(_searchTecnicos);
    on<TecnicoSearchMenuEvent>(_searchMenuTecnicos);
    on<TecnicoRegisterEvent>(_registerTecnico);
    on<TecnicoUpdateEvent>(_updateTecnico);
    on<TecnicoDisableListEvent>(_deleteListTecnicos);
  }

  Future<void> _fetchAllTecnicos(
      TecnicoLoadingEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest<PageContent<TecnicoResponse>>(
      emit: emit,
      request: () => _tecnicoClient.fetchListByFilter(
        id: event.id,
        nome: event.nome,
        situacao: event.situacao,
        equipamento: event.equipamento,
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<TecnicoResponse> pageTecnicos) =>
          emit(TecnicoSearchSuccessState(
        tecnicos: pageTecnicos.content,
        currentPage: pageTecnicos.page.page,
        totalPages: pageTecnicos.page.totalPages,
        totalElements: pageTecnicos.page.totalElements,
      )),
    );
  }

  Future<void> _fetchOneTecnico(
      TecnicoSearchOneEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest<Tecnico?>(
        emit: emit,
        loading: TecnicoSearchOneLoadingState(),
        request: () => _tecnicoClient.fetchOneById(event.id),
        onSuccess: (Tecnico? tecnico) {
          if (tecnico != null) {
            emit(TecnicoSearchOneSuccessState(tecnico: tecnico));
          }
        });
  }

  Future<void> _fetchAvailability(
      TecnicoAvailabilitySearchEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest<List<TecnicoDisponivel>>(
      emit: emit,
      request: () => _tecnicoClient
          .fetchListAvailabilityBySpecialityId(event.idEspecialidade),
      onSuccess: (List<TecnicoDisponivel> tecnicosDisponiveis) => emit(
          TecnicoSearchAvailabilitySuccessState(
              tecnicosDisponiveis: tecnicosDisponiveis)),
    );
  }

  Future<void> _searchTecnicos(
      TecnicoSearchEvent event, Emitter<TecnicoState> emit) async {
    add(TecnicoLoadingEvent(
      id: event.id,
      nome: event.nome,
      situacao: event.situacao,
      equipamento: event.equipamento,
    ));
  }

  Future<void> _searchMenuTecnicos(
      TecnicoSearchMenuEvent event, Emitter<TecnicoState> emit) async {
    idMenu = event.id;
    nomeMenu = event.nome ?? nomeMenu;
    situacaoMenu =
        (event.situacao?.isNotEmpty == true && event.situacao != null)
            ? event.situacao!.toLowerCase()
            : situacaoMenu;

    situacaoMenu = (isFirstRequest)
        ? Constants.situationTecnicoList.first.toLowerCase()
        : situacaoMenu;
    isFirstRequest = false;

    add(TecnicoLoadingEvent(
      id: idMenu,
      nome: nomeMenu,
      situacao: situacaoMenu,
      equipamento: event.equipamento,
    ));
  }

  Future<void> _registerTecnico(
      TecnicoRegisterEvent event, Emitter<TecnicoState> emit) async {
    event.tecnico.sobrenome = event.sobrenome;
    await handleRequest(
        emit: emit,
        request: () => _tecnicoClient.create(event.tecnico),
        onSuccess: (_) => emit(TecnicoRegisterSuccessState()));
  }

  Future<void> _updateTecnico(
      TecnicoUpdateEvent event, Emitter<TecnicoState> emit) async {
    event.tecnico.sobrenome = event.sobrenome;
    await handleRequest(
        emit: emit,
        request: () => _tecnicoClient.update(event.tecnico),
        onSuccess: (_) => emit(TecnicoUpdateSuccessState()));
  }

  Future<void> _deleteListTecnicos(
      TecnicoDisableListEvent event, Emitter<TecnicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _tecnicoClient.disableListByIds(event.selectedList),
      onSuccess: (_) => add(TecnicoLoadingEvent(
        id: idMenu,
        nome: nomeMenu,
        situacao: situacaoMenu,
      )),
    );
  }
}
