import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_clean_architecture/core/error/failures.dart';
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
  }

  FutureOr<void> eventGetTriviaForConcreteNumber(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) {
    final inputEither = inputConverter.stringToUnsignedInt(event.numberString);

    inputEither
        .fold((failure) => emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
            (integer) async {
      emit(Loading());
      final failureOrTrivia = await concrete(Params(number: integer));
      failureOrTrivia.fold(
          (failure) => emit(
                Error(
                  message: failure is ServerFailure
                      ? SERVER_FAILURE_MESSAGE
                      : CACHE_FAILURE_MESSAGE,
                ),
              ),
          (trivia) => emit(Loaded(trivia: trivia)));
    });
  }
}
