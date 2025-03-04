import 'package:bloc/bloc.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

abstract class BaseEntityBloc<Event, State> extends Bloc<Event, State> {
  BaseEntityBloc(super.initialState);

  State loadingState();
  State errorState(ErrorEntity error);

  Future<void> handleRequest<T>({
    required Emitter<State> emit,
    required Future<T> Function() request,
    required void Function(T result) onSuccess,
    void Function(ErrorEntity error)? onError,
  }) async {
    emit(loadingState());
    try {
      final result = await request();
      onSuccess(result);
    }
    catch (e) {
      final ErrorEntity error = (e is ErrorEntity) ? e : ErrorEntity(id: 0, errorMessage: "Erro ao processar a requisição!");

      if (onError != null) {
        onError(error);
      }
      else {
        emit(errorState(error));
      }
    }
  }
}
