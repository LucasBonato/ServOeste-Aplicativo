import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';
import 'package:serv_oeste/src/repository/servico_repository.dart';

part 'servico_event.dart';
part 'servico_state.dart';

class ServicoBloc extends Bloc<ServicoEvent, ServicoState> {
  final ServicoRepository _servicoRepository = ServicoRepository();

  ServicoBloc() : super(ServicoInitialState()) {
    on<ServicoLoadingEvent>(_fetchAllServices);
    on<ServicoSearchOneEvent>(_fetchOneService);
    on<ServicoSearchEvent>(_searchServices);
    on<ServicoRegisterEvent>(_registerService);
    on<ServicoUpdateEvent>(_updateService);
    on<ServicoDeleteEvent>(_deleteService);
  }

  Future<void> _fetchAllServices(ServicoLoadingEvent event, Emitter emit) async {
    emit(ServicoLoadingState());
    try {
      List<Servico>? servicos = await _servicoRepository.getServicosByFilter(event.filterRequest);
      emit(ServicoSearchSuccessState(servicos: servicos?? []));
    } on DioException {
      emit(ServicoErrorState());
    }
  }

  Future<void> _fetchOneService(ServicoSearchOneEvent event, Emitter emit) async {

  }

  Future<void> _searchServices(ServicoSearchEvent event, Emitter emit) async {

  }

  Future<void> _registerService(ServicoRegisterEvent event, Emitter emit) async {

  }

  Future<void> _updateService(ServicoUpdateEvent event, Emitter emit) async {

  }

  Future<void> _deleteService(ServicoDeleteEvent event, Emitter emit) async {

  }
}