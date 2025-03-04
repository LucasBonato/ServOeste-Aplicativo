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
  ServicoFilterRequest? filterRequest;
  bool isFirstRequest = true;

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

    emit(ServicoLoadingState());
    try {
      List<Servico>? response = await _servicoRepository.getServicosByFilter(filterRequest!);
      emit(ServicoSearchSuccessState(servicos: response ?? []));
    } on DioException catch (e) {
      emit(ServicoErrorState(
        error: ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    }
  }

  Future<void> _fetchAllServicesInitial(ServicoInitialLoadingEvent event, Emitter<ServicoState> emit) async {
    emit(ServicoLoadingState());
    try {
      List<Servico>? response = await _servicoRepository.getServicosByFilter(event.filterRequest);
      emit(ServicoSearchSuccessState(servicos: response ?? []));
    }
    on DioException catch (e) {
      emit(ServicoErrorState(
        error: ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    }
  }

  Future<void> _fetchServiceSearchMenu(ServicoSearchMenuEvent event, Emitter<ServicoState> emit) async {
    filterRequest = event.filterRequest?? filterRequest;
    filterRequest = filterRequest?? ServicoFilterRequest();

    if (filterRequest != null && event.filterRequest != null) {
      filterRequest = _combineFilters(filterRequest!, event.filterRequest!);
    }

    emit(ServicoLoadingState());
    try {
      List<Servico>? response = await _servicoRepository.getServicosByFilter(filterRequest!);
      emit(ServicoSearchSuccessState(servicos: response ?? []));
    }
    on DioException catch (e) {
      emit(ServicoErrorState(
        error: ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    }
  }

  Future<void> _fetchOneService(ServicoSearchOneEvent event, Emitter emit) async {
    emit(ServicoLoadingState());
    try {
      final List<Servico>? servicos = await _servicoRepository.getServicosByFilter(ServicoFilterRequest(id: event.id));
      if (servicos != null) {
        emit(ServicoSearchOneSuccessState(servico: servicos[0]));
        return;
      }
      emit(ServicoErrorState(error: ErrorEntity(id: 0, errorMessage: "")));
    } on DioException catch (e) {
      emit(ServicoErrorState(error: ErrorEntity(id: 0, errorMessage: e.toString())));
    }
  }

  Future<void> _registerService(ServicoRegisterEvent event, Emitter emit) async {
    emit(ServicoLoadingState());
    ErrorEntity? error = await _servicoRepository.createServicoComClienteExistente(event.servico);
    emit((error == null) ? ServicoRegisterSuccessState() : ServicoErrorState(error: error));
  }

  Future<void> _registerServicePlusClient(ServicoRegisterPlusClientEvent event, Emitter emit) async {
    emit(ServicoLoadingState());
    ErrorEntity? error = await _servicoRepository.createServicoComClienteNaoExistente(event.servico, event.cliente);
    emit((error == null) ? ServicoRegisterSuccessState() : ServicoErrorState(error: error));
  }

  Future<void> _updateService(ServicoUpdateEvent event, Emitter emit) async {
    emit(ServicoLoadingState());
    try {
      Servico? servico = await _servicoRepository.putServico(event.servico);
      if (servico != null) {
        emit(ServicoUpdateSuccessState(servico: servico));
      }
    } catch (e) {
      emit(ServicoErrorState(error: e as ErrorEntity));
    }
  }

  Future<void> _deleteService(ServicoDisableListEvent event, Emitter<ServicoState> emit) async {
    emit(ServicoLoadingState());
    try {
      await _servicoRepository.disableListOfServico(event.selectedList);
      await _fetchServiceSearchMenu(ServicoSearchMenuEvent(), emit);
    } catch (e) {
      emit(ServicoErrorState(
        error: ErrorEntity(id: 0, errorMessage: "Erro ao deletar serviço"),
      ));
    }
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
