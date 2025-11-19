import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';

abstract class BaseEntityBloc<Event, State> extends Bloc<Event, State> {
  BaseEntityBloc(super.initialState);

  State loadingState();

  State errorState(ErrorEntity error);

  Future<void> handleRequest<T>({
    required Emitter<State> emit,
    required Future<Either<ErrorEntity, T>> Function() request,
    required FutureOr<void> Function(T result) onSuccess,
    void Function(ErrorEntity error)? onError,
    State? loading,
  }) async {
    emit(loading ?? loadingState());
    final Either<ErrorEntity, T> result = await request();

    await result.fold((ErrorEntity error) {
      if (onError != null) {
        onError(error);
      }
      else {
        emit(errorState(error));
      }
    },
    (T success) async {
      await onSuccess(success);
    });
  }
}
