import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/cliente_repository.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteBloc extends Bloc<ClienteEvent, ClienteState> {
  final ClienteRepository clienteRepository = ClienteRepository();
  String? _nome, _telefone, _endereco;

  ClienteBloc() : super(ClienteInitialState()) {
    on<ClienteLoadingEvent>(_fetchAllClients);
    on<ClienteSearchEvent>(_searchClients);
    //on<ClienteToggleItemSelectEvent>(_toggleItemsSelected);
    on<ClienteDeleteListEvent>(_deleteListClients);
  }

  Future<void> _fetchAllClients(ClienteLoadingEvent event, Emitter emit) async {
    emit(ClienteLoadingState());
    try {
      final List<Cliente>? response = await clienteRepository.getClientesByFind(
        nome: event.nome,
        telefone: event.telefone,
        endereco: event.endereco
      );
      emit(ClienteSuccessState(clientes: response?? []));
    } catch (e) {
      emit(ClienteErrorState(error: ErrorEntity(id: 0, error: e.toString())));
    }
  }

  Future<void> _searchClients(ClienteSearchEvent event, Emitter emit) async {
    _nome = event.nome?.isNotEmpty == true ? event.nome : null;
    _telefone = event.telefone?.isNotEmpty == true ? event.telefone : null;
    _endereco = event.endereco?.isNotEmpty == true ? event.endereco : null;
    await _fetchAllClients(ClienteLoadingEvent(nome: _nome, telefone: _telefone, endereco: _endereco), emit);
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

  Future<void> _deleteListClients(ClienteDeleteListEvent event, Emitter emit) async {
    emit(ClienteLoadingEvent());
    try {
      await clienteRepository.deleteClientes(event.selectedList);
      await _fetchAllClients(ClienteLoadingEvent(nome: _nome, telefone: _telefone, endereco: _endereco), emit);
    } catch(e) {
      emit(ClienteErrorState(error: ErrorEntity(id: 0, error: "")));
    }
  }
}