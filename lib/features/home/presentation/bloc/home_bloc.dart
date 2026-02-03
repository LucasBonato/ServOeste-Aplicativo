import 'package:bloc/bloc.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_filter.dart';
import 'package:serv_oeste/features/servico/domain/servico_repository.dart';
import 'package:serv_oeste/shared/bloc/base_entity_bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/shared/models/page_content.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends BaseEntityBloc<HomeEvent, HomeState> {
  final ServicoRepository _servicoRepository;

  @override
  HomeState loadingState() => HomeLoadingState();

  @override
  HomeState errorState(ErrorEntity error) => HomeErrorState(error: error);

  HomeBloc(this._servicoRepository) : super(HomeInitialState()) {
    on<HomeSearchEvent>(_fetchServices);
  }

  Future<void> _fetchServices(HomeSearchEvent event, Emitter<HomeState> emit) async {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime week = startOfDay.add(Duration(days: 7));

    final ServicoFilter filter = ServicoFilter(
      dataAtendimentoPrevistoAntes: startOfDay,
      dataAtendimentoPrevistoDepois: week,
    );

    await handleRequest<PageContent<Servico>>(
      emit: emit,
      request: () => _servicoRepository.getServicosByFilter(
        filter: filter,
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<Servico> pageServicos) => emit(
        HomeSearchSuccessState(
          servicos: pageServicos.content,
          currentPage: pageServicos.page.page,
          totalPages: pageServicos.page.totalPages,
          totalElements: pageServicos.page.totalElements,
        ),
      ),
    );
  }
}
