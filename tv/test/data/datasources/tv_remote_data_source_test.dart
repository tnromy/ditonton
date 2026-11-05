import 'dart:convert';

import 'package:core/core.dart';
import 'package:tv/data/datasources/tv_remote_data_source.dart';
import 'package:tv/data/models/season_detail_model.dart';
import 'package:tv/data/models/tv_detail_model.dart';
import 'package:tv/data/models/tv_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';
import '../../json_reader.dart';

void main() {
  const apiKey = 'api_key=2174d146bb9c0eab47529b2e77d6b526';
  const baseUrl = 'https://api.themoviedb.org/3';

  late TvRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = TvRemoteDataSourceImpl(client: mockHttpClient);
  });

  void stub(String path, String body, int code) {
    when(() => mockHttpClient.get(Uri.parse('$baseUrl$path')))
        .thenAnswer((_) async => http.Response(body, code));
  }

  final listCases = <String, (String, String, Future Function())>{
    'On The Air': (
      '/tv/on_the_air?$apiKey',
      'dummy_data/on_the_air.json',
      () => dataSource.getOnTheAirTv(),
    ),
    'Popular': (
      '/tv/popular?$apiKey',
      'dummy_data/popular_tv.json',
      () => dataSource.getPopularTv(),
    ),
    'Top Rated': (
      '/tv/top_rated?$apiKey',
      'dummy_data/top_rated_tv.json',
      () => dataSource.getTopRatedTv(),
    ),
    'Recommendations': (
      '/tv/1/recommendations?$apiKey',
      'dummy_data/tv_recommendations.json',
      () => dataSource.getTvRecommendations(1),
    ),
    'Search': (
      '/search/tv?$apiKey&query=got',
      'dummy_data/search_got_tv.json',
      () => dataSource.searchTv('got'),
    ),
  };

  listCases.forEach((name, testCase) {
    final (path, fixture, call) = testCase;

    group('get $name TV', () {
      test(
        'should return list of TvModel when the response code is 200',
        () async {
          stub(path, readJson(fixture), 200);
          final expected = TvResponse.fromJson(json.decode(readJson(fixture)))
              .tvList;
          final result = await call();
          expect(result, equals(expected));
        },
      );

      test(
        'should throw ServerException when the response code is not 200',
        () async {
          stub(path, 'Not Found', 404);
          expect(() => call(), throwsA(isA<ServerException>()));
        },
      );
    });
  });

  group('get TV Detail', () {
    const path = '/tv/1?$apiKey';

    test(
      'should return TvDetailResponse when the response code is 200',
      () async {
        stub(path, readJson('dummy_data/tv_detail.json'), 200);
        final expected = TvDetailResponse.fromJson(
          json.decode(readJson('dummy_data/tv_detail.json')),
        );
        final result = await dataSource.getTvDetail(1);
        expect(result, equals(expected));
      },
    );

    test(
      'should throw ServerException when the response code is not 200',
      () async {
        stub(path, 'Not Found', 404);
        expect(
          () => dataSource.getTvDetail(1),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('get TV Season Detail', () {
    const path = '/tv/1399/season/1?$apiKey';

    test(
      'should return SeasonDetailResponse when the response code is 200',
      () async {
        stub(path, readJson('dummy_data/season_detail.json'), 200);
        final expected = SeasonDetailResponse.fromJson(
          json.decode(readJson('dummy_data/season_detail.json')),
        );
        final result = await dataSource.getTvSeasonDetail(1399, 1);
        expect(result, equals(expected));
        expect(result.episodes.length, 2);
      },
    );

    test(
      'should throw ServerException when the response code is not 200',
      () async {
        stub(path, 'Not Found', 404);
        expect(
          () => dataSource.getTvSeasonDetail(1399, 1),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
