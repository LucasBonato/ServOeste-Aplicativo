import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/clients/servico_client.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';

part 'servico_event.dart';
part 'servico_state.dart';

class ServicoBloc extends BaseEntityBloc<ServicoEvent, ServicoState> {
  final ServicoClient _servicoClient = ServicoClient();
  ServicoFilterRequest? filterRequest;
  bool isFirstRequest = true;

  @override
  ServicoState loadingState() => ServicoLoadingState();

  @override
  ServicoState errorState(ErrorEntity error) => ServicoErrorState(error: error);

  ServicoBloc() : super(ServicoInitialState()) {
    on<ServicoLoadingEvent>(_fetchAllServicesWithFilter);
    on<ServicoInitialLoadingEvent>(_fetchAllServicesInitial);
    on<ServicoSearchMenuEvent>(_fetchServiceSearchMenu);
    on<ServicoSearchOneEvent>(_fetchOneService);
    on<ServicoRegisterEvent>(_registerService);
    on<ServicoRegisterPlusClientEvent>(_registerServicePlusClient);
    on<ServicoUpdateEvent>(_updateService);
    on<ServicoDisableListEvent>(_deleteService);
  }

  Future<void> _fetchAllServicesWithFilter(ServicoLoadingEvent event, Emitter<ServicoState> emit) async {
    filterRequest = _combineFilters(filterRequest?? ServicoFilterRequest(), event.filterRequest);

    await handleRequest<List<Servico>>(
      emit: emit,
      request: () => _servicoClient.getServicosByFilter(filterRequest!),
      onSuccess: (List<Servico> servicos) => emit(ServicoSearchSuccessState(servicos: servicos))
    );
  }

  Future<void> _fetchAllServicesInitial(ServicoInitialLoadingEvent event, Emitter<ServicoState> emit) async {
    await handleRequest<List<Servico>>(
      emit: emit,
      request: () => _servicoClient.getServicosByFilter(event.filterRequest),
      onSuccess: (List<Servico> servicos) => emit(ServicoSearchSuccessState(servicos: servicos))
    );
  }

  Future<void> _fetchServiceSearchMenu(ServicoSearchMenuEvent event, Emitter<ServicoState> emit) async {
    filterRequest = event.filterRequest?? filterRequest;
    filterRequest = filterRequest?? ServicoFilterRequest();

    if (filterRequest != null && event.filterRequest != null) {
      filterRequest = _combineFilters(filterRequest!, event.filterRequest!);
    }

    await handleRequest<List<Servico>>(
      emit: emit,
      request: () => _servicoClient.getServicosByFilter(filterRequest!),
      onSuccess: (List<Servico> servicos) => emit(ServicoSearchSuccessState(servicos: servicos))
    );
  }

  Future<void> _fetchOneService(ServicoSearchOneEvent event, Emitter<ServicoState> emit) async {
    await handleRequest<List<Servico>>(
      emit: emit,
      request: () => _servicoClient.getServicosByFilter(ServicoFilterRequest(id: event.id)),
      onSuccess: (List<Servico> servicos) => emit(ServicoSearchOneSuccessState(servico: servicos[0]))
    );
  }

  Future<void> _registerService(ServicoRegisterEvent event, Emitter<ServicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _servicoClient.createServicoComClienteExistente(event.servico),
      onSuccess: (_) => emit(ServicoRegisterSuccessState())
    );
  }

  Future<void> _registerServicePlusClient(ServicoRegisterPlusClientEvent event, Emitter<ServicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _servicoClient.createServicoComClienteNaoExistente(event.servico, event.cliente),
      onSuccess: (_) => emit(ServicoRegisterSuccessState())
    );
  }

  Future<void> _updateService(ServicoUpdateEvent event, Emitter<ServicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _servicoClient.putServico(event.servico),
      onSuccess: (_) => emit(ServicoUpdateSuccessState())
    );
  }

  Future<void> _deleteService(ServicoDisableListEvent event, Emitter<ServicoState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _servicoClient.disableListOfServico(event.selectedList),
      onSuccess: (_) => emit(ServicoUpdateSuccessState())
    );
    await _fetchServiceSearchMenu(ServicoSearchMenuEvent(), emit);
  }

  ServicoFilterRequest _combineFilters(ServicoFilterRequest oldFilter, ServicoFilterRequest newFilter) {
    int? id;
    String? periodo;
    String? equipamento;
    String? situacao;
    String? garantia;
    String? filial;
    DateTime? dataAtendimentoPrevistoAntes;
    DateTime? dataAtendimentoPrevistoDepois;
    DateTime? dataAtendimentoEfetivoAntes;
    DateTime? dataAberturaAntes;

    if (isFirstRequest) {
      id = newFilter.id;
      periodo = newFilter.periodo;
      equipamento = newFilter.equipamento;
      situacao = newFilter.situacao;
      garantia = newFilter.garantia;
      filial = newFilter.filial;
      dataAtendimentoPrevistoAntes = newFilter.dataAtendimentoPrevistoAntes;
      dataAtendimentoPrevistoDepois = newFilter.dataAtendimentoPrevistoDepois;
      dataAtendimentoEfetivoAntes = newFilter.dataAtendimentoEfetivoAntes;
      dataAberturaAntes = newFilter.dataAberturaAntes;
      isFirstRequest = false;
    } else {
      id = newFilter.id ?? oldFilter.id;
      periodo = newFilter.periodo ?? oldFilter.periodo;
      equipamento = newFilter.equipamento ?? oldFilter.equipamento;
      situacao = newFilter.situacao ?? oldFilter.situacao;
      garantia = newFilter.garantia ?? oldFilter.garantia;
      filial = newFilter.filial ?? oldFilter.filial;
      dataAtendimentoPrevistoAntes = newFilter.dataAtendimentoPrevistoAntes ?? oldFilter.dataAtendimentoPrevistoAntes;
      dataAtendimentoPrevistoDepois = newFilter.dataAtendimentoPrevistoDepois ?? oldFilter.dataAtendimentoPrevistoDepois;
      dataAtendimentoEfetivoAntes = newFilter.dataAtendimentoEfetivoAntes ?? oldFilter.dataAtendimentoEfetivoAntes;
      dataAberturaAntes = newFilter.dataAberturaAntes ?? oldFilter.dataAberturaAntes;
      isFirstRequest = true;
    }

    return ServicoFilterRequest(
      id: id,
      clienteNome: newFilter.clienteNome ?? oldFilter.clienteNome,
      tecnicoNome: newFilter.tecnicoNome ?? oldFilter.tecnicoNome,
      equipamento: equipamento,
      situacao: situacao,
      garantia: garantia,
      filial: filial,
      periodo: periodo,
      dataAtendimentoPrevistoAntes: dataAtendimentoPrevistoAntes,
      dataAtendimentoPrevistoDepois: dataAtendimentoPrevistoDepois,
      dataAtendimentoEfetivoAntes: dataAtendimentoEfetivoAntes,
      dataAberturaAntes: dataAberturaAntes,
    );
  }
}
