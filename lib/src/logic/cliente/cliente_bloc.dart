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
    on<ClienteDisableListEvent>(_deleteListClients);
    on<ClienteUpdateEvent>(_updateClient);
    on<ClienteRegisterEvent>(_registerClient);
    on<RestoreClienteStateEvent>(_restoreState);
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

  Future<void> _fetchAllClients(
      ClienteLoadingEvent event, Emitter<ClienteState> emit) async {
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
        error:
            ErrorEntity(id: 0, errorMessage: e.message ?? 'Erro desconhecido'),
      ));
    } catch (e) {
      emit(ClienteErrorState(
        error: ErrorEntity(id: 0, errorMessage: 'Erro ao buscar clientes'),
      ));
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
      ClienteDisableListEvent event, Emitter<ClienteState> emit) async {
    emit(ClienteLoadingState());
    List<Cliente>? existingClientes = [];

    try {
      if (state is ClienteSearchSuccessState) {
        existingClientes = (state as ClienteSearchSuccessState).clientes;
      } else if (state is ClienteErrorState) {
        existingClientes = (state as ClienteErrorState).clientes;
      }

      await _clienteRepository.deleteClientes(event.selectedList);
    } catch (e) {
      int errorId = 0;
      String errorMessage = "Erro desconhecido";

      if (e is Exception && e.toString().contains("ErrorEntity")) {
        final errorEntity = e.toString();
        final regex = RegExp(r"ErrorEntity\(id: (\d+), message: (.+)\)");
        final match = regex.firstMatch(errorEntity);

        if (match != null) {
          errorId = int.tryParse(match.group(1) ?? '0') ?? 0;
          errorMessage = match.group(2) ?? errorMessage;
        }
      }

      emit(ClienteErrorState(
        clientes: existingClientes,
        error: ErrorEntity(id: errorId, errorMessage: errorMessage),
      ));
    } finally {
      await _fetchAllClients(
        ClienteLoadingEvent(
          nome: _nome,
          telefone: _telefone,
          endereco: _endereco,
        ),
        emit,
      );
    }
  }

  Future<void> _restoreState(
      RestoreClienteStateEvent event, Emitter<ClienteState> emit) async {
    emit(event.state);
  }
}
