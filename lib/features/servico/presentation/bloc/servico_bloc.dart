import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_request.dart';
import 'package:serv_oeste/features/servico/domain/servico_repository.dart';
import 'package:serv_oeste/shared/bloc/base_entity_bloc.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_request.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';

part 'servico_event.dart';
part 'servico_state.dart';

class ServicoBloc extends BaseEntityBloc<ServicoEvent, ServicoState> {
  final ServicoRepository _servicoRepository;

  @override
  ServicoState loadingState() => ServicoLoadingState();

  @override
  ServicoState errorState(ErrorEntity error) => ServicoErrorState(error: error);

  ServicoBloc(this._servicoRepository) : super(ServicoInitialState()) {
    on<ServicoSearchOneEvent>(_fetchOneService);
    on<ServicoSearchEvent>(_fetchAllServices);
    on<ServicoRegisterEvent>(_registerService);
    on<ServicoRegisterPlusClientEvent>(_registerServicePlusClient);
    on<ServicoUpdateEvent>(_updateService);
    on<ServicoDisableListEvent>(_deleteService);
  }

  Future<void> _fetchOneService(
      ServicoSearchOneEvent event, Emitter<ServicoState> emit) async {
    await handleRequest<Servico?>(
      emit: emit,
      loading: ServicoSearchOneLoadingState(),
      request: () => _servicoRepository.getServicoById(event.id),
      onSuccess: (Servico? servico) {
        if (servico != null) {
          emit(ServicoSearchOneSuccessState(servico: servico));
        }
      },
    );
  }

  Future<void> _fetchAllServices(
      ServicoSearchEvent event, Emitter<ServicoState> emit) async {
    await handleRequest<PageContent<Servico>>(
      emit: emit,
      request: () => _servicoRepository.getServicosByFilter(
        filter: event.filter,
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<Servico> pageServicos) => emit(
        ServicoSearchSuccessState(
          servicos: pageServicos.content,
          currentPage: pageServicos.page.page,
          totalPages: pageServicos.page.totalPages,
          totalElements: pageServicos.page.totalElements,
          filter: event.filter,
        ),
      ),
    );
  }

  Future<void> _registerService(
      ServicoRegisterEvent event, Emitter<ServicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () =>
          _servicoRepository.createServicoComClienteExistente(event.servico),
      onSuccess: (_) => emit(ServicoRegisterSuccessState()),
    );
  }

  Future<void> _registerServicePlusClient(
      ServicoRegisterPlusClientEvent event, Emitter<ServicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _servicoRepository.createServicoComClienteNaoExistente(
          event.servico, event.cliente),
      onSuccess: (_) => emit(ServicoRegisterSuccessState()),
    );
  }

  Future<void> _updateService(
      ServicoUpdateEvent event, Emitter<ServicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _servicoRepository.update(event.servico),
      onSuccess: (_) => emit(ServicoUpdateSuccessState()),
    );
  }

  Future<void> _deleteService(
      ServicoDisableListEvent event, Emitter<ServicoState> emit) async {
    ServicoFilter? currentFilter;

    if (state is ServicoSearchSuccessState) {
      final ServicoSearchSuccessState currentState =
          (state as ServicoSearchSuccessState);
      currentFilter = currentState.filter;
    }

    await handleRequest(
      emit: emit,
      request: () =>
          _servicoRepository.disableListOfServico(event.selectedList),
      onSuccess: (_) {
        if (currentFilter != null) {
          add(ServicoSearchEvent(filter: currentFilter));
        }
      },
    );
  }
}
