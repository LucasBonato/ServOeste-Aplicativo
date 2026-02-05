import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter_request.dart';
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
  ServicoFilterRequest? filterRequest;
  bool isFirstRequest = true;

  @override
  ServicoState loadingState() => ServicoLoadingState();

  @override
  ServicoState errorState(ErrorEntity error) => ServicoErrorState(error: error);

  ServicoBloc(this._servicoRepository) : super(ServicoInitialState()) {
    on<ServicoLoadingEvent>(_fetchAllServicesWithFilter);
    on<ServicoInitialLoadingEvent>(_fetchAllServicesInitial);
    on<ServicoSearchMenuEvent>(_fetchServiceSearchMenu);
    on<ServicoSearchOneEvent>(_fetchOneService);
    on<ServicoRegisterEvent>(_registerService);
    on<ServicoRegisterPlusClientEvent>(_registerServicePlusClient);
    on<ServicoUpdateEvent>(_updateService);
    on<ServicoDisableListEvent>(_deleteService);
  }

  Future<void> _fetchAllServicesWithFilter(
      ServicoLoadingEvent event, Emitter<ServicoState> emit) async {
    emit(ServicoLoadingState());
    filterRequest = _combineFilters(
        filterRequest ?? ServicoFilterRequest(), event.filterRequest);

    await handleRequest<PageContent<Servico>>(
      emit: emit,
      request: () => _servicoRepository.getServicosByFilter(
        filterRequest!,
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<Servico> pageServicos) =>
          emit(ServicoSearchSuccessState(
        servicos: pageServicos.content,
        currentPage: pageServicos.page.page,
        totalPages: pageServicos.page.totalPages,
        totalElements: pageServicos.page.totalElements,
      )),
    );
  }

  Future<void> _fetchAllServicesInitial(
      ServicoInitialLoadingEvent event, Emitter<ServicoState> emit) async {
    await handleRequest<PageContent<Servico>>(
      emit: emit,
      request: () => _servicoRepository.getServicosByFilter(
        event.filterRequest,
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<Servico> pageServicos) =>
          emit(ServicoSearchSuccessState(
        servicos: pageServicos.content,
        currentPage: pageServicos.page.page,
        totalPages: pageServicos.page.totalPages,
        totalElements: pageServicos.page.totalElements,
      )),
    );
  }

  Future<void> _fetchServiceSearchMenu(
      ServicoSearchMenuEvent event, Emitter<ServicoState> emit) async {
    emit(ServicoLoadingState());
    filterRequest =
        event.filterRequest ?? filterRequest ?? ServicoFilterRequest();

    if (filterRequest != null && event.filterRequest != null) {
      filterRequest = _combineFilters(filterRequest!, event.filterRequest!);
    }

    await handleRequest<PageContent<Servico>>(
      emit: emit,
      request: () => _servicoRepository.getServicosByFilter(
        filterRequest!,
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<Servico> pageServicos) =>
          emit(ServicoSearchSuccessState(
        servicos: pageServicos.content,
        currentPage: pageServicos.page.page,
        totalPages: pageServicos.page.totalPages,
        totalElements: pageServicos.page.totalElements,
      )),
    );
  }

  Future<void> _fetchOneService(
      ServicoSearchOneEvent event, Emitter<ServicoState> emit) async {
    await handleRequest<Servico?>(
      emit: emit,
      loading: ServicoSearchOneLoadingState(),
      request: () => _servicoRepository.getServicoById(event.id),
      onSuccess: (Servico? servico) =>
          emit(ServicoSearchOneSuccessState(servico: servico!)),
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
    await handleRequest(
      emit: emit,
      request: () =>
          _servicoRepository.disableListOfServico(event.selectedList),
      onSuccess: (_) => emit(ServicoUpdateSuccessState()),
    );
    await _fetchServiceSearchMenu(ServicoSearchMenuEvent(), emit);
  }

  ServicoFilterRequest _combineFilters(
      ServicoFilterRequest oldFilter, ServicoFilterRequest newFilter) {
    int? id;
    int? clienteId;
    int? tecnicoId;
    String? periodo;
    String? equipamento;
    String? marca;
    String? situacao;
    String? garantia;
    String? filial;
    DateTime? dataAtendimentoPrevistoAntes;
    DateTime? dataAtendimentoPrevistoDepois;
    DateTime? dataAtendimentoEfetivoAntes;
    DateTime? dataAtendimentoEfetivoDepois;
    DateTime? dataAberturaAntes;
    DateTime? dataAberturaDepois;

    if (isFirstRequest) {
      id = newFilter.id;
      clienteId = newFilter.clienteId;
      tecnicoId = newFilter.tecnicoId;
      periodo = newFilter.periodo;
      equipamento = newFilter.equipamento;
      marca = newFilter.marca;
      situacao = newFilter.situacao;
      garantia = newFilter.garantia;
      filial = newFilter.filial;
      dataAtendimentoPrevistoAntes = newFilter.dataAtendimentoPrevistoAntes;
      dataAtendimentoPrevistoDepois = newFilter.dataAtendimentoPrevistoDepois;
      dataAtendimentoEfetivoAntes = newFilter.dataAtendimentoEfetivoAntes;
      dataAtendimentoEfetivoDepois = newFilter.dataAtendimentoEfetivoDepois;
      dataAberturaAntes = newFilter.dataAberturaAntes;
      dataAberturaDepois = newFilter.dataAberturaDepois;
      isFirstRequest = false;
    } else {
      id = newFilter.id ?? oldFilter.id;
      clienteId = newFilter.clienteId ?? oldFilter.clienteId;
      tecnicoId = newFilter.tecnicoId ?? oldFilter.tecnicoId;
      periodo = newFilter.periodo ?? oldFilter.periodo;
      equipamento = newFilter.equipamento ?? oldFilter.equipamento;
      marca = newFilter.marca ?? oldFilter.marca;
      situacao = newFilter.situacao ?? oldFilter.situacao;
      garantia = newFilter.garantia ?? oldFilter.garantia;
      filial = newFilter.filial ?? oldFilter.filial;
      dataAtendimentoPrevistoAntes = newFilter.dataAtendimentoPrevistoAntes ??
          oldFilter.dataAtendimentoPrevistoAntes;
      dataAtendimentoPrevistoDepois = newFilter.dataAtendimentoPrevistoDepois ??
          oldFilter.dataAtendimentoPrevistoDepois;
      dataAtendimentoEfetivoAntes = newFilter.dataAtendimentoEfetivoAntes ??
          oldFilter.dataAtendimentoEfetivoAntes;
      dataAtendimentoEfetivoDepois = newFilter.dataAtendimentoEfetivoDepois ??
          oldFilter.dataAtendimentoEfetivoDepois;
      dataAberturaAntes =
          newFilter.dataAberturaAntes ?? oldFilter.dataAberturaAntes;
      dataAberturaDepois =
          newFilter.dataAberturaDepois ?? oldFilter.dataAberturaDepois;
      isFirstRequest = true;
    }

    return ServicoFilterRequest(
      id: id,
      clienteId: clienteId,
      tecnicoId: tecnicoId,
      clienteNome: newFilter.clienteNome ?? oldFilter.clienteNome,
      tecnicoNome: newFilter.tecnicoNome ?? oldFilter.tecnicoNome,
      equipamento: equipamento,
      marca: marca,
      situacao: situacao,
      garantia: garantia,
      filial: filial,
      periodo: periodo,
      dataAtendimentoPrevistoAntes: dataAtendimentoPrevistoAntes,
      dataAtendimentoPrevistoDepois: dataAtendimentoPrevistoDepois,
      dataAtendimentoEfetivoAntes: dataAtendimentoEfetivoAntes,
      dataAtendimentoEfetivoDepois: dataAtendimentoEfetivoDepois,
      dataAberturaAntes: dataAberturaAntes,
      dataAberturaDepois: dataAberturaDepois,
    );
  }
}
