part of 'cliente_bloc.dart';

@immutable
sealed class ClienteEvent {}

final class ClienteLoadingEvent extends ClienteEvent {}