part of 'endereco_bloc.dart';

@immutable
sealed class EnderecoEvent {}

final class EnderecoSearchCepEvent extends EnderecoEvent {
  final String cep;

  EnderecoSearchCepEvent({
    required this.cep
  });
}