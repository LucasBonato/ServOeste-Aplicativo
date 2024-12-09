import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/cliente_repository.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteBloc extends Bloc<ClienteEvent, ClienteState> {
  final ClienteRepository _clienteRepository = ClienteRepository();
  String? _nome, _telefone, _endereco;

  ClienteBloc() : super(ClienteInitialState()) {
    on<ClienteSearchOneEvent>(_fetchOneClient);
    on<ClienteLoadingEvent>(_fetchAllClients);
    on<ClienteSearchEvent>(_searchClients);
    on<ClienteDeleteListEvent>(_deleteListClients);
    on<ClienteUpdateEvent>(_updateClient);
    on<ClienteRegisterEvent>(_registerClient);
  }

  Future<void> _fetchOneClient(
      ClienteSearchOneEvent event, Emitter<ClienteState> emit) async {
    emit(ClienteLoadingState());
    try {
      final Cliente? cliente =
          await _clienteRepository.getClienteById(id: event.id);
      if (cliente != null) {
        emit(ClienteSearchOneSuccessState(cliente: cliente));
        return;
      }
      emit(ClienteErrorState(error: ErrorEntity(id: 0, errorMessage: "")));
    } on DioException catch (e) {
      emit(ClienteErrorState(
          error: ErrorEntity(id: 0, errorMessage: e.toString())));
    }
  }

  Future<void> _fetchAllClients(ClienteLoadingEvent event, Emitter<ClienteState> emit) async {
    emit(ClienteLoadingState());
    try {
      final List<Cliente>? response =
          await _clienteRepository.getClientesByFind(
        nome: event.nome,
        telefone: event.telefone,
        endereco: event.endereco,
      );
      emit(ClienteSearchSuccessState(clientes: response ?? []));
    } on DioException catch (e) {
      emit(ClienteErrorState(
          error: ErrorEntity(id: 0, errorMessage: e.toString())));
    }
  }

  Future<void> _searchClients(
      ClienteSearchEvent event, Emitter<ClienteState> emit) async {
    _nome = event.nome?.isNotEmpty == true ? event.nome : null;
    _telefone = event.telefone?.isNotEmpty == true ? event.telefone : null;
    _endereco = event.endereco?.isNotEmpty == true ? event.endereco : null;
    await _fetchAllClients(
      ClienteLoadingEvent(
          nome: _nome, telefone: _telefone, endereco: _endereco),
      emit,
    );
  }

  Future<void> _registerClient(
      ClienteRegisterEvent event, Emitter<ClienteState> emit) async {
    emit(ClienteLoadingState());
    try {
      ErrorEntity? error =
          await _clienteRepository.postCliente(event.cliente, event.sobrenome);
      emit((error == null)
          ? ClienteRegisterSuccessState()
          : ClienteErrorState(error: error));
    } catch (e) {
      emit(ClienteErrorState(
          error: ErrorEntity(id: 0, errorMessage: "Algo deu errado!")));
    }
  }

  Future<void> _updateClient(
      ClienteUpdateEvent event, Emitter<ClienteState> emit) async {
    emit(ClienteLoadingState());
    try {
      ErrorEntity? error =
          await _clienteRepository.putCliente(event.cliente, event.sobrenome);
      emit(error == null
          ? ClienteUpdateSuccessState()
          : ClienteErrorState(error: error));
    } catch (e) {
      emit(ClienteErrorState(
          error: ErrorEntity(id: 0, errorMessage: "Algo deu errado!")));
    }
  }

  Future<void> _deleteListClients(
      ClienteDeleteListEvent event, Emitter<ClienteState> emit) async {
    emit(ClienteLoadingState());
    try {
      await _clienteRepository.deleteClientes(event.selectedList);
      await _fetchAllClients(
        ClienteLoadingEvent(
            nome: _nome, telefone: _telefone, endereco: _endereco),
        emit,
      );
    } catch (e) {
      emit(ClienteErrorState(
          error: ErrorEntity(id: 0, errorMessage: "Erro ao deletar clientes")));
    }
  }
}
