import 'package:flutter_clean_architecture/core/error/failures.dart';
import 'package:flutter_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture/core/util/input_converter.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([
  GetConcreteNumberTrivia,
  GetRandomNumberTrivia,
  InputConverter,
])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('InitialState shoul be empty', () {
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInt(any))
            .thenReturn(Right(tNumberParsed));

    void setUpmockGetConcreteNumberTrivia() =>
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));

    blocTest(
      'should call the InputConverter to validate and convert the string to an unsigned int',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpmockGetConcreteNumberTrivia();
      },
      act: (NumberTriviaBloc bloc) {
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      verify: (bloc) {
        verify(mockInputConverter.stringToUnsignedInt(tNumberString));
      },
    );

    blocTest(
      'should emit [Error] when the input is invalid',
      build: () => bloc,
      setUp: () {
        when(mockInputConverter.stringToUnsignedInt(any))
            .thenReturn(Left(InvalidInputFailure()));
      },
      act: (NumberTriviaBloc bloc) =>
          bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ],
    );

    blocTest(
      'should get data from the concrete use case',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpmockGetConcreteNumberTrivia();
      },
      act: (NumberTriviaBloc bloc) =>
          bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      verify: (bloc) {
        verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );

    blocTest(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpmockGetConcreteNumberTrivia();
      },
      expect: () => [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ],
      act: (NumberTriviaBloc bloc) {
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );
    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
      },
      expect: () => [
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ],
      act: (NumberTriviaBloc bloc) {
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    blocTest(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      act: (NumberTriviaBloc bloc) {
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: () => [
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockGetRandomNumberTrivia() =>
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));

    blocTest(
      'should get data from the random use case',
      build: () => bloc,
      setUp: () {
        setUpMockGetRandomNumberTrivia();
      },
      act: (NumberTriviaBloc bloc) => bloc.add(GetTriviaForRandomNumber()),
      verify: (bloc) {
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    blocTest(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () => bloc,
      setUp: () {
        setUpMockGetRandomNumberTrivia();
      },
      expect: () => [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ],
      act: (NumberTriviaBloc bloc) {
        bloc.add(GetTriviaForRandomNumber());
      },
    );
    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () => bloc,
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
      },
      expect: () => [
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ],
      act: (NumberTriviaBloc bloc) {
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    blocTest(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () => bloc,
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      act: (NumberTriviaBloc bloc) {
        bloc.add(GetTriviaForRandomNumber());
      },
      expect: () => [
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ],
    );
  });
}
