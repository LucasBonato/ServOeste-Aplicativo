import 'package:meta/meta.dart';

@immutable
sealed class DisponibilidadeEvent {}

class DisponibilidadesSearchEvent extends DisponibilidadeEvent {
  final int especialidadeId;

  DisponibilidadesSearchEvent(this.especialidadeId);
}
