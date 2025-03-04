import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/logic/base_entity_bloc.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/endereco_repository.dart';

part 'endereco_event.dart';

part 'endereco_state.dart';

class EnderecoBloc extends BaseEntityBloc<EnderecoEvent, EnderecoState> {
  final EnderecoRepository _enderecoRepository = EnderecoRepository();

  @override
  EnderecoState errorState(ErrorEntity error) => EnderecoErrorState(errorMessage: error.errorMessage);

  @override
  EnderecoState loadingState() => EnderecoLoadingState();

  EnderecoBloc() : super(EnderecoInitialState()) {
    on<EnderecoSearchCepEvent>(_fetchEnderecoByCep);
  }

  Future<void> _fetchEnderecoByCep(EnderecoSearchCepEvent event, Emitter<EnderecoState> emit) async {
    await handleRequest<Endereco?>(
      emit: emit,
      request: () => _enderecoRepository.getEndereco(event.cep),
      onSuccess: (Endereco? endereco) {
        if (endereco != null && endereco.endereco != null) {
          List<String> camposSobreEndereco = endereco.endereco!.split("|");
          String rua = camposSobreEndereco[0];
          String bairro = camposSobreEndereco[1];
          String municipio = camposSobreEndereco[2];
          emit(EnderecoSuccessState(rua: rua, numero: "", complemento: "", bairro: bairro, municipio: municipio));
        }
      },
      onError: (error) => emit(EnderecoErrorState(errorMessage: "Endereço não encontrado!"))
    );
  }
}
