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
  String? _nome, _telefone, _rua, _numero, _complemento, _cep;

  ClienteBloc() : super(ClienteInitialState()) {
    on<ClienteSearchOneEvent>(_fetchOneClient);
    on<ClienteLoadingEvent>(_fetchAllClients);
    on<ClienteSearchEvent>(_searchClients);
    on<ClienteDeleteListEvent>(_deleteListClients);
    on<ClienteUpdateEvent>(_updateClient);
    on<ClienteRegisterEvent>(_registerClient);
    // on<ClienteToggleItemSelectEvent>(_toggleItemsSelected);
  }

  Future<void> _fetchOneClient(
      ClienteSearchOneEvent event, Emitter emit) async {
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
      emit(ClienteErrorState(error: e as ErrorEntity));
    }
  }

  Future<void> _fetchAllClients(ClienteLoadingEvent event, Emitter emit) async {
    emit(ClienteLoadingState());
    try {
      final List<Cliente>? response =
          await _clienteRepository.getClientesByFind(
        nome: event.nome,
        telefone: event.telefone,
        rua: event.rua,
        numero: event.numero,
      );

      emit(ClienteSearchSuccessState(clientes: response ?? []));
    } on DioException catch (e) {
      emit(ClienteErrorState(
          error: ErrorEntity(id: 0, errorMessage: e.toString())));
    }
  }

  Future<void> _searchClients(ClienteSearchEvent event, Emitter emit) async {
    _nome = event.nome?.isNotEmpty == true ? event.nome : null;
    _telefone = event.telefone?.isNotEmpty == true ? event.telefone : null;
    _rua = event.rua?.isNotEmpty == true ? event.rua : null;
    _numero = event.numero?.isNotEmpty == true ? event.numero : null;

    await _fetchAllClients(
      ClienteLoadingEvent(
        nome: _nome,
        telefone: _telefone,
        rua: _rua,
        numero: _numero,
      ),
      emit,
    );
  }

  Future<void> _registerClient(ClienteRegisterEvent event, Emitter emit) async {
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

  Future<void> _updateClient(ClienteUpdateEvent event, Emitter emit) async {
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
      ClienteDeleteListEvent event, Emitter emit) async {
    emit(ClienteLoadingState());
    try {
      await _clienteRepository.deleteClientes(event.selectedList);
      await _fetchAllClients(
        ClienteLoadingEvent(
          nome: _nome,
          telefone: _telefone,
          rua: _rua,
          numero: _numero,
          complemento: _complemento,
          cep: _cep,
        ),
        emit,
      );
    } catch (e) {
      emit(ClienteErrorState(error: ErrorEntity(id: 0, errorMessage: "")));
    }
  }

  // Future<void> _toggleItemsSelected(ClienteToggleItemSelectEvent event, Emitter emit) {
  //   final newSelectedItems = List<int>.from(state.selectedItems);
  //
  //   if (newSelectedItems.contains(event.id)) {
  //     newSelectedItems.remove(event.id);
  //   } else {
  //     newSelectedItems.add(event.id);
  //   }
  //
  //   emit(ClienteSelectedItemsState(selectedItems: newSelectedItems));
  // }
}
