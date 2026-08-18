import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/core/observability/tracing.dart';

abstract class BaseEntityBloc<TEvent, TState> extends Bloc<TEvent, TState> {
  BaseEntityBloc(super.initialState);

  @override
  void on<E extends TEvent>(
    EventHandler<E, TState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(
      (E event, Emitter<TState> emit) => Tracing.trace(
        Tracing.spanNameFromEvent(event.runtimeType),
        attributes: {'bloc.event': event.runtimeType.toString()},
        fn: () async => handler(event, emit),
      ),
    );
  }

  TState loadingState();

  TState errorState(ErrorEntity error);

  Future<void> handleRequest<T>({
    required Emitter<TState> emit,
    required Future<Either<ErrorEntity, T>> Function() request,
    required FutureOr<void> Function(T result) onSuccess,
    FutureOr<void> Function(ErrorEntity error)? onError,
    TState? loading,
  }) async {
    emit(loading ?? loadingState());
    final Either<ErrorEntity, T> result = await request();

    await result.fold((ErrorEntity error) async {
      if (onError != null) {
        await onError(error);
      } else {
        emit(errorState(error));
      }
    }, (T success) async {
      await onSuccess(success);
    });
  }
}
