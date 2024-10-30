part of 'endereco_bloc.dart';

@immutable
sealed class EnderecoState {}

final class EnderecoInitialState extends EnderecoState {}

final class EnderecoLoadingState extends EnderecoState {}

final class EnderecoSuccessState extends EnderecoState {
  final String? endereco;
  final String? municipio;
  final String? bairro;

  EnderecoSuccessState({
    required this.endereco,
    required this.municipio,
    required this.bairro
  });
}

final class EnderecoErrorState extends EnderecoState {
  final ErrorEntity error;

  EnderecoErrorState({
    required this.error
  });
}