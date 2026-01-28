import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/features/cliente/domain/cliente_repository.dart';
import 'package:serv_oeste/shared/bloc/base_entity_bloc.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/page_content.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteBloc extends BaseEntityBloc<ClienteEvent, ClienteState> {
  final ClienteRepository _repository;

  String? nomeMenu;
  String? telefoneMenu;
  String? enderecoMenu;

  @override
  ClienteState loadingState() => ClienteLoadingState();

  @override
  ClienteState errorState(ErrorEntity error) => ClienteErrorState(error: error);

  ClienteBloc(this._repository) : super(ClienteInitialState()) {
    on<ClienteSearchOneEvent>(_fetchOneClient);
    on<ClienteLoadingEvent>(_fetchAllClients);
    on<ClienteSearchEvent>(_searchClients);
    on<ClienteSearchMenuEvent>(_searchMenuClients);
    on<ClienteDeleteListEvent>(_deleteListClients);
    on<ClienteUpdateEvent>(_updateClient);
    on<ClienteRegisterEvent>(_registerClient);
    on<RestoreClienteStateEvent>(_restoreState);
  }

  Future<void> _fetchOneClient(ClienteSearchOneEvent event, Emitter<ClienteState> emit) async {
    await handleRequest<Cliente?>(
      emit: emit,
      loading: ClienteSearchOneLoadingState(),
      request: () => _repository.fetchOneById(id: event.id),
      onSuccess: (Cliente? cliente) {
        if (cliente != null) {
          emit(ClienteSearchOneSuccessState(cliente: cliente));
        }
      },
    );
  }

  Future<void> _fetchAllClients(ClienteLoadingEvent event, Emitter<ClienteState> emit) async {
    await handleRequest<PageContent<Cliente>>(
      emit: emit,
      request: () => _repository.fetchListByFilter(
        nome: event.nome,
        telefone: event.telefone,
        endereco: event.endereco,
        page: event.page,
        size: event.size,
      ),
      onSuccess: (PageContent<Cliente> pageClientes) => emit(ClienteSearchSuccessState(
        clientes: pageClientes.content,
        currentPage: pageClientes.page.page,
        totalPages: pageClientes.page.totalPages,
        totalElements: pageClientes.page.totalElements,
      )),
    );
  }

  Future<void> _searchClients(ClienteSearchEvent event, Emitter<ClienteState> emit) async {
    add(ClienteLoadingEvent(
      nome: event.nome,
      telefone: event.telefone,
      endereco: event.endereco,
    ));
  }

  Future<void> _searchMenuClients(ClienteSearchMenuEvent event, Emitter<ClienteState> emit) async {
    nomeMenu = event.nome ?? nomeMenu;
    telefoneMenu = event.telefone ?? telefoneMenu;
    enderecoMenu = event.endereco ?? enderecoMenu;
    add(ClienteLoadingEvent(
      nome: nomeMenu,
      telefone: telefoneMenu,
      endereco: enderecoMenu,
    ));
  }

  Future<void> _registerClient(ClienteRegisterEvent event, Emitter<ClienteState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _repository.create(event.cliente, event.sobrenome),
      onSuccess: (_) => emit(ClienteRegisterSuccessState()),
      onError: (error) => emit(ClienteErrorState(error: error)),
    );
  }

  Future<void> _updateClient(ClienteUpdateEvent event, Emitter<ClienteState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _repository.update(event.cliente, event.sobrenome),
      onSuccess: (_) => emit(ClienteUpdateSuccessState()),
      onError: (error) => emit(ClienteErrorState(error: error)),
    );
  }

  Future<void> _deleteListClients(ClienteDeleteListEvent event, Emitter<ClienteState> emit) async {
    List<Cliente> existingClientes = [];

    if (state is ClienteSearchSuccessState) {
      existingClientes = (state as ClienteSearchSuccessState).clientes;
    } else if (state is ClienteErrorState) {
      existingClientes = (state as ClienteErrorState).clientes ?? [];
    }

    await handleRequest(
      emit: emit,
      request: () => _repository.deleteListByIds(event.selectedList),
      onSuccess: (_) => add(ClienteLoadingEvent(
        nome: nomeMenu,
        telefone: telefoneMenu,
        endereco: enderecoMenu,
      )),
      onError: (error) => emit(ClienteErrorState(error: error, clientes: existingClientes)),
    );
  }

  Future<void> _restoreState(RestoreClienteStateEvent event, Emitter<ClienteState> emit) async {
    emit(event.state);
  }
}
