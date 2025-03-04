import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/cliente_repository.dart';

part 'cliente_event.dart';

part 'cliente_state.dart';

class ClienteBloc extends BaseEntityBloc<ClienteEvent, ClienteState> {
  final ClienteRepository _clienteRepository = ClienteRepository();
  String? _nome, _telefone, _endereco,
      nomeMenu, telefoneMenu, enderecoMenu;

  @override
  ClienteState loadingState() => ClienteLoadingState();

  @override
  ClienteState errorState(ErrorEntity error) => ClienteErrorState(error: error);

  ClienteBloc() : super(ClienteInitialState()) {
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
      request: () => _clienteRepository.fetchOneById(id: event.id),
      onSuccess: (Cliente? cliente) {
        if (cliente != null) {
          emit(ClienteSearchOneSuccessState(cliente: cliente));
        }
      }
    );
  }

  Future<void> _fetchAllClients(ClienteLoadingEvent event, Emitter<ClienteState> emit) async {
    await handleRequest<List<Cliente>>(
      emit: emit,
      request: () => _clienteRepository.fetchListByFilter(
        nome: event.nome,
        telefone: event.telefone,
        endereco: event.endereco,
      ),
      onSuccess: (List<Cliente> clientes) {
        emit(ClienteSearchSuccessState(clientes: clientes));
      }
    );
  }

  Future<void> _searchClients(ClienteSearchEvent event, Emitter<ClienteState> emit) async {
    _nome = (event.nome?.isNotEmpty == true) ? event.nome : null;
    _telefone = (event.telefone?.isNotEmpty == true) ? event.telefone : null;
    _endereco = (event.endereco?.isNotEmpty == true) ? event.endereco : null;
    add(ClienteLoadingEvent(nome: _nome, telefone: _telefone, endereco: _endereco));
  }

  Future<void> _searchMenuClients(ClienteSearchMenuEvent event, Emitter<ClienteState> emit) async {
    nomeMenu = event.nome?? nomeMenu;
    telefoneMenu = event.telefone?? telefoneMenu;
    enderecoMenu = event.endereco?? enderecoMenu;
    add(ClienteLoadingEvent(nome: nomeMenu, telefone: telefoneMenu, endereco: enderecoMenu));
  }

  Future<void> _registerClient(ClienteRegisterEvent event, Emitter<ClienteState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _clienteRepository.create(event.cliente, event.sobrenome),
      onSuccess: (_) => emit(ClienteRegisterSuccessState()),
      onError: (error) => emit(ClienteErrorState(error: error))
    );
  }

  Future<void> _updateClient(ClienteUpdateEvent event, Emitter<ClienteState> emit) async {
    await handleRequest(
      emit: emit,
      request: () => _clienteRepository.update(event.cliente, event.sobrenome),
      onSuccess: (_) => emit(ClienteUpdateSuccessState()),
      onError: (error) => emit(ClienteErrorState(error: error))
    );
  }

  Future<void> _deleteListClients(ClienteDeleteListEvent event, Emitter<ClienteState> emit) async {
    List<Cliente> existingClientes = [];

    if (state is ClienteSearchSuccessState) {
      existingClientes = (state as ClienteSearchSuccessState).clientes;
    }
    else if (state is ClienteErrorState) {
      existingClientes = (state as ClienteErrorState).clientes?? [];
    }
    
    await handleRequest(
      emit: emit, 
      request: () => _clienteRepository.deleteListByIds(event.selectedList), 
      onSuccess: (_) => add(ClienteLoadingEvent(nome: _nome, endereco: _endereco, telefone: _telefone)),
      onError: (error) => emit(ClienteErrorState(error: error, clientes: existingClientes))
    );
  }

  Future<void> _restoreState(RestoreClienteStateEvent event, Emitter<ClienteState> emit) async {
    emit(event.state);
  }
}
