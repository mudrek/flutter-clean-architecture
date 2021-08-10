import 'dart:convert';

import 'package:flutter_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';

import 'package:http/http.dart' as http;

import '../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart' as mocks;

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late mocks.MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = mocks.MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
        // act
        dataSource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockHttpClient.get(
          Uri(path: 'http://numbersapi.com/$tNumber'),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
        // act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);
        // assert dando errado
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response('Something went wrong', 404));
        // act
        final call = dataSource.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(isA<ServerException>()));
      },
    );
  });
}