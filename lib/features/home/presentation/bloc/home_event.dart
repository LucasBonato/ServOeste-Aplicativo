part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class HomeSearchEvent extends HomeEvent {
  final int page;
  final int size;

  HomeSearchEvent({
    this.page = 0,
    this.size = 15,
  });
}
