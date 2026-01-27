import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/features/endereco/data/endereco_client.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

part 'endereco_event.dart';
part 'endereco_state.dart';

class EnderecoBloc extends BaseEntityBloc<EnderecoEvent, EnderecoState> {
  final EnderecoClient _enderecoClient;

  @override
  EnderecoState errorState(ErrorEntity error) => EnderecoErrorState(errorMessage: error.detail);

  @override
  EnderecoState loadingState() => EnderecoLoadingState();

  EnderecoBloc(this._enderecoClient) : super(EnderecoInitialState()) {
    on<EnderecoSearchCepEvent>(_fetchEnderecoByCep);
  }

  Future<void> _fetchEnderecoByCep(EnderecoSearchCepEvent event, Emitter<EnderecoState> emit) async {
    await handleRequest<Endereco?>(
        emit: emit,
        request: () => _enderecoClient.getEndereco(event.cep),
        onSuccess: (Endereco? endereco) {
          if (endereco != null && endereco.logradouro != null) {
            emit(EnderecoSuccessState(rua: endereco.logradouro ?? "", numero: "", complemento: "", bairro: endereco.bairro ?? "", municipio: endereco.municipio ?? ""));
          }
        },
        onError: (error) => emit(EnderecoErrorState(errorMessage: "Endereço não encontrado!")));
  }
}
