import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';

abstract class BaseEntityBloc<TEvent, TState> extends Bloc<TEvent, TState> {
  BaseEntityBloc(super.initialState);

  TState loadingState();

  TState errorState(ErrorEntity error);

  Future<void> handleRequest<T>({
    required Emitter<TState> emit,
    required Future<Either<ErrorEntity, T>> Function() request,
    required FutureOr<void> Function(T result) onSuccess,
    void Function(ErrorEntity error)? onError,
    TState? loading,
  }) async {
    emit(loading ?? loadingState());
    final Either<ErrorEntity, T> result = await request();

    await result.fold((ErrorEntity error) {
      if (onError != null) {
        onError(error);
      } else {
        emit(errorState(error));
      }
    }, (T success) async {
      await onSuccess(success);
    });
  }
}
