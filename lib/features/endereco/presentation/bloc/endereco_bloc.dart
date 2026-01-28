import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:serv_oeste/features/endereco/domain/endereco_repository.dart';
import 'package:serv_oeste/shared/bloc/base_entity_bloc.dart';
import 'package:serv_oeste/features/endereco/domain/entities/endereco.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

part 'endereco_event.dart';
part 'endereco_state.dart';

class EnderecoBloc extends BaseEntityBloc<EnderecoEvent, EnderecoState> {
  final EnderecoRepository _enderecoRepository;

  @override
  EnderecoState errorState(ErrorEntity error) => EnderecoErrorState(errorMessage: error.detail);

  @override
  EnderecoState loadingState() => EnderecoLoadingState();

  EnderecoBloc(this._enderecoRepository) : super(EnderecoInitialState()) {
    on<EnderecoSearchCepEvent>(_fetchEnderecoByCep);
  }

  Future<void> _fetchEnderecoByCep(EnderecoSearchCepEvent event, Emitter<EnderecoState> emit) async {
    await handleRequest<Endereco?>(
      emit: emit,
      request: () => _enderecoRepository.getEndereco(event.cep),
      onSuccess: (Endereco? endereco) {
        if (endereco != null && endereco.logradouro != null) {
          emit(EnderecoSuccessState(
            rua: endereco.logradouro ?? "",
            numero: "",
            complemento: "",
            bairro: endereco.bairro ?? "",
            municipio: endereco.municipio ?? "",
          ));
        }
      },
      onError: (error) => emit(EnderecoErrorState(errorMessage: "Endereço não encontrado!")),
    );
  }
}
