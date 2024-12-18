import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/repository/servico_repository.dart';

part 'servico_event.dart';
part 'servico_state.dart';

class ServicoBloc extends Bloc<ServicoEvent, ServicoState> {
  final ServicoRepository _servicoRepository = ServicoRepository();
  late ServicoFilterRequest _filterRequest = ServicoFilterRequest();

  ServicoBloc() : super(ServicoInitialState()) {
    on<ServicoLoadingEvent>(_fetchAllServices);
    on<ServicoSearchOneEvent>(_fetchOneService);
    on<ServicoSearchEvent>(_searchServices);
    on<ServicoRegisterEvent>(_registerService);
    on<ServicoRegisterPlusClientEvent>(_registerServicePlusClient);
    on<ServicoUpdateEvent>(_updateService);
    on<ServicoDisableListEvent>(_deleteService);
  }

  Future<void> _fetchAllServices(
      ServicoLoadingEvent event, Emitter<ServicoState> emit) async {
    _filterRequest = _combineFilters(_filterRequest, event.filterRequest);

    emit(ServicoLoadingState());
    try {
      List<Servico>? response =
          await _servicoRepository.getServicosByFilter(_filterRequest);
      emit(ServicoSearchSuccessState(servicos: response ?? []));
    } on DioException catch (e) {
      emit(ServicoErrorState(
        error:
            ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    }
  }

  ServicoFilterRequest _combineFilters(
      ServicoFilterRequest oldFilter, ServicoFilterRequest newFilter) {
    return ServicoFilterRequest(
      id: newFilter.id ?? oldFilter.id,
      clienteNome: (newFilter.clienteNome?.isNotEmpty ?? false)
          ? newFilter.clienteNome
          : oldFilter.clienteNome,
      tecnicoNome: (newFilter.tecnicoNome?.isNotEmpty ?? false)
          ? newFilter.tecnicoNome
          : oldFilter.tecnicoNome,
      equipamento: (newFilter.equipamento?.isNotEmpty ?? false)
          ? newFilter.equipamento
          : oldFilter.equipamento,
      situacao: (newFilter.situacao?.isNotEmpty ?? false)
          ? newFilter.situacao
          : oldFilter.situacao,
      garantia: (newFilter.garantia?.isNotEmpty ?? false)
          ? newFilter.garantia
          : oldFilter.garantia,
      filial: (newFilter.filial?.isNotEmpty ?? false)
          ? newFilter.filial
          : oldFilter.filial,
      periodo: (newFilter.periodo?.isNotEmpty ?? false)
          ? newFilter.periodo
          : oldFilter.periodo,
      dataAtendimentoPrevistoAntes: newFilter.dataAtendimentoPrevistoAntes ??
          oldFilter.dataAtendimentoPrevistoAntes,
      dataAtendimentoEfetivoAntes: newFilter.dataAtendimentoEfetivoAntes ??
          oldFilter.dataAtendimentoEfetivoAntes,
      dataAberturaAntes:
          newFilter.dataAberturaAntes ?? oldFilter.dataAberturaAntes,
    );
  }

  Future<void> _fetchOneService(
      ServicoSearchOneEvent event, Emitter emit) async {}

  Future<void> _searchServices(ServicoSearchEvent event, Emitter emit) async {}

  Future<void> _registerService(
      ServicoRegisterEvent event, Emitter emit) async {
    emit(ServicoLoadingState());
    ErrorEntity? error = await _servicoRepository
        .createServicoComClienteExistente(event.servico);
    emit((error == null)
        ? ServicoRegisterSuccessState()
        : ServicoErrorState(error: error));
  }

  Future<void> _registerServicePlusClient(
      ServicoRegisterPlusClientEvent event, Emitter emit) async {
    emit(ServicoLoadingState());
    ErrorEntity? error = await _servicoRepository
        .createServicoComClienteNaoExistente(event.servico, event.cliente);
    emit((error == null)
        ? ServicoRegisterSuccessState()
        : ServicoErrorState(error: error));
  }

  Future<void> _updateService(ServicoUpdateEvent event, Emitter emit) async {}

  Future<void> _deleteService(
      ServicoDisableListEvent event, Emitter<ServicoState> emit) async {
    emit(ServicoLoadingState());
    try {
      await _servicoRepository.disableListOfServico(event.selectedList);
      await _fetchAllServices(
          ServicoLoadingEvent(filterRequest: _filterRequest), emit);
    } catch (e) {
      emit(ServicoErrorState(
        error: ErrorEntity(id: 0, errorMessage: "Erro ao deletar serviço"),
      ));
    }
  }
}
