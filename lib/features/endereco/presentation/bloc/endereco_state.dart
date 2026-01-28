part of 'endereco_bloc.dart';

@immutable
sealed class EnderecoState {}

final class EnderecoInitialState extends EnderecoState {}

final class EnderecoLoadingState extends EnderecoState {}

final class EnderecoSuccessState extends EnderecoState {
  final String rua;
  final String numero;
  final String complemento;
  final String municipio;
  final String bairro;

  EnderecoSuccessState({
    required this.rua,
    required this.numero,
    required this.complemento,
    required this.municipio,
    required this.bairro,
  });
}

final class EnderecoErrorState extends EnderecoState {
  final String errorMessage;

  EnderecoErrorState({
    required this.errorMessage,
  });
}
