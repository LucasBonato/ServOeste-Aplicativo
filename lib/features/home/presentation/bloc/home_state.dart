part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitialState extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeSearchSuccessState extends HomeState {
  final List<Servico> servicos;
  final int totalElements;
  final int currentPage;
  final int totalPages;

  HomeSearchSuccessState({
    required this.servicos,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });
}

final class HomeErrorState extends HomeState {
  final ErrorEntity error;

  HomeErrorState({required this.error});
}
