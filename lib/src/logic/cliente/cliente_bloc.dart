import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/cliente_repository.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteBloc extends Bloc<ClienteEvent, ClienteState> {
  final ClienteRepository clienteRepository = ClienteRepository();

  ClienteBloc() : super(ClienteInitialState()) {
    on<ClienteLoadingEvent>(_fetchAllClients);
  }

  Future<void> _fetchAllClients(ClienteLoadingEvent event, Emitter emit) async {
    emit(ClienteLoadingState());
    try {
      final List<Cliente>? response = await clienteRepository.getClientesByFind(null, null, null);
      emit(ClienteSuccessState(clientes: response?? []));
    } catch (e) {
      emit(ClienteErrorState(error: ErrorEntity(id: 0, error: e.toString())));
    }
  }
}
