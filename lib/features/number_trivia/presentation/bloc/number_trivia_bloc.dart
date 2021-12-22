import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia concrete;
  final GetRandomNumberTrivia random;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.concrete,
    required this.random,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(eventGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(eventGetTriviaForRandomNumber);
  }

  FutureOr<void> eventGetTriviaForConcreteNumber(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) {
    final inputEither = inputConverter.stringToUnsignedInt(event.numberString);

    inputEither.fold(
      (failure) => emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
      (integer) async {
        emit(Loading());
        final failureOrTrivia = await concrete(Params(number: integer));
        _eitherLoadedOrErrorState(failureOrTrivia, emit);
      },
    );
  }

  FutureOr<void> eventGetTriviaForRandomNumber(
      GetTriviaForRandomNumber event, Emitter<NumberTriviaState> emit) async {
    emit(Loading());
    final failureOrTrivia = await random(NoParams());
    _eitherLoadedOrErrorState(failureOrTrivia, emit);
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> failureOrTrivia,
      Emitter<NumberTriviaState> emit) {
    failureOrTrivia.fold(
        (failure) => emit(Error(message: _mapFailureToMessage(failure))),
        (trivia) => emit(Loaded(trivia: trivia)));
  }

  _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
