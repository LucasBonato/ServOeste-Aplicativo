import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/src/models/endereco/endereco.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/repository/endereco_repository.dart';

part 'endereco_event.dart';
part 'endereco_state.dart';

class EnderecoBloc extends Bloc<EnderecoEvent, EnderecoState> {
  final EnderecoRepository _enderecoRepository = EnderecoRepository();

  EnderecoBloc() : super(EnderecoInitialState()) {
    on<EnderecoSearchCepEvent>(_fetchEnderecoByCep);
  }

  Future<void> _fetchEnderecoByCep(
      EnderecoSearchCepEvent event, Emitter emit) async {
    emit(EnderecoLoadingState());
    try {
      Endereco? enderecoEntity =
          await _enderecoRepository.getEndereco(event.cep);

      if (enderecoEntity != null && enderecoEntity.endereco != null) {
        List<String> camposSobreEndereco = enderecoEntity.endereco!.split("|");
        String rua = camposSobreEndereco[0];
        String bairro = camposSobreEndereco[1];
        String municipio = camposSobreEndereco[2];
        emit(
          EnderecoSuccessState(
            rua: rua,
            numero: "",
            complemento: "",
            bairro: bairro,
            municipio: municipio,
          ),
        );
        return;
      }
      emit(EnderecoErrorState(errorMessage: "Endereço não encontrado"));
    } catch (e) {
      if (e is ErrorEntity) {
        emit(EnderecoErrorState(errorMessage: e.errorMessage));
      } else {
        emit(EnderecoErrorState(errorMessage: "Erro desconhecido"));
      }
    }
  }
}
