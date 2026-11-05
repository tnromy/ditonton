import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tv/data/models/tv_model.dart';
import 'package:tv/data/models/tv_detail_model.dart';
import 'package:tv/data/models/episode_model.dart';
import 'package:core/core.dart';
import 'package:tv/data/models/season_detail_model.dart';
import 'package:tv/data/models/season_model.dart';
import 'package:tv/data/repositories/tv_repository_impl.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late TvRepositoryImpl repository;
  late MockTvRemoteDataSource mockRemoteDataSource;
  late MockTvLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockTvRemoteDataSource();
    mockLocalDataSource = MockTvLocalDataSource();
    repository = TvRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tTvModel = TvModel(
    backdropPath: '/path.jpg',
    genreIds: [1, 2, 3],
    id: 1,
    originalName: 'Original Name',
    overview: 'overview',
    popularity: 1,
    posterPath: '/path.jpg',
    firstAirDate: '2021-10-12',
    name: 'Name',
    voteAverage: 1,
    voteCount: 1,
  );

  final tTv = Tv(
    backdropPath: '/path.jpg',
    genreIds: [1, 2, 3],
    id: 1,
    originalName: 'Original Name',
    overview: 'overview',
    popularity: 1,
    posterPath: '/path.jpg',
    firstAirDate: '2021-10-12',
    name: 'Name',
    voteAverage: 1,
    voteCount: 1,
  );

  final tTvModelList = <TvModel>[tTvModel];
  final tTvList = <Tv>[tTv];

  group('On The Air Tv', () {
    test('should return remote data when the call to remote data source is successful', () async {
      when(() => mockRemoteDataSource.getOnTheAirTv())
          .thenAnswer((_) async => tTvModelList);
      final result = await repository.getOnTheAirTv();
      verify(() => mockRemoteDataSource.getOnTheAirTv());
      final resultList = result.getOrElse(() => []);
      expect(resultList, tTvList);
    });

    test('should return server failure when the call to remote data source is unsuccessful', () async {
      when(() => mockRemoteDataSource.getOnTheAirTv())
          .thenThrow(ServerException());
      final result = await repository.getOnTheAirTv();
      verify(() => mockRemoteDataSource.getOnTheAirTv());
      expect(result, equals(Left(ServerFailure(''))));
    });

    test('should return connection failure when the device is not connected to internet', () async {
      when(() => mockRemoteDataSource.getOnTheAirTv())
          .thenThrow(SocketException('Failed to connect to the network'));
      final result = await repository.getOnTheAirTv();
      verify(() => mockRemoteDataSource.getOnTheAirTv());
      expect(
        result,
        equals(Left(ConnectionFailure('Failed to connect to the network'))),
      );
    });
  });

  group('Popular Tv', () {
    test('should return tv list when call to data source is success', () async {
      when(() => mockRemoteDataSource.getPopularTv())
          .thenAnswer((_) async => tTvModelList);
      final result = await repository.getPopularTv();
      final resultList = result.getOrElse(() => []);
      expect(resultList, tTvList);
    });

    test(
      'should return server failure when call to data source is unsuccessful',
      () async {
        when(() => mockRemoteDataSource.getPopularTv())
            .thenThrow(ServerException());
        final result = await repository.getPopularTv();
        expect(result, Left(ServerFailure('')));
      },
    );

    test('should return connection failure when device is not connected to the internet', () async {
      when(() => mockRemoteDataSource.getPopularTv())
          .thenThrow(SocketException('Failed to connect to the network'));
      final result = await repository.getPopularTv();
      expect(
        result,
        Left(ConnectionFailure('Failed to connect to the network')),
      );
    });
  });

  group('Top Rated Tv', () {
    test(
      'should return tv list when call to data source is successful',
      () async {
        when(() => mockRemoteDataSource.getTopRatedTv())
            .thenAnswer((_) async => tTvModelList);
        final result = await repository.getTopRatedTv();
        final resultList = result.getOrElse(() => []);
        expect(resultList, tTvList);
      },
    );

    test(
      'should return ServerFailure when call to data source is unsuccessful',
      () async {
        when(() => mockRemoteDataSource.getTopRatedTv())
            .thenThrow(ServerException());
        final result = await repository.getTopRatedTv();
        expect(result, Left(ServerFailure('')));
      },
    );

    test('should return ConnectionFailure when device is not connected to the internet', () async {
      when(() => mockRemoteDataSource.getTopRatedTv())
          .thenThrow(SocketException('Failed to connect to the network'));
      final result = await repository.getTopRatedTv();
      expect(
        result,
        Left(ConnectionFailure('Failed to connect to the network')),
      );
    });
  });

  group('Get Tv Detail', () {
    final tId = 1;
    final tTvResponse = TvDetailResponse(
      backdropPath: 'backdropPath',
      genres: [GenreModel(id: 1, name: 'Action')],
      id: 1,
      originalName: 'originalName',
      overview: 'overview',
      posterPath: 'posterPath',
      firstAirDate: 'firstAirDate',
      name: 'name',
      numberOfEpisodes: 10,
      numberOfSeasons: 1,
      seasons: [
        SeasonModel(
          id: 3624,
          name: 'Season 1',
          seasonNumber: 1,
          episodeCount: 10,
          posterPath: '/season1.jpg',
          airDate: '2011-04-17',
        ),
      ],
      voteAverage: 1,
      voteCount: 1,
    );

    test(
      'should return Tv data when the call to remote data source is successful',
      () async {
        when(() => mockRemoteDataSource.getTvDetail(tId))
            .thenAnswer((_) async => tTvResponse);
        final result = await repository.getTvDetail(tId);
        verify(() => mockRemoteDataSource.getTvDetail(tId));
        expect(result, equals(Right(testTvDetail)));
      },
    );

    test('should return Server Failure when the call to remote data source is unsuccessful', () async {
      when(() => mockRemoteDataSource.getTvDetail(tId))
          .thenThrow(ServerException());
      final result = await repository.getTvDetail(tId);
      verify(() => mockRemoteDataSource.getTvDetail(tId));
      expect(result, equals(Left(ServerFailure(''))));
    });

    test('should return connection failure when the device is not connected to internet', () async {
      when(() => mockRemoteDataSource.getTvDetail(tId))
          .thenThrow(SocketException('Failed to connect to the network'));
      final result = await repository.getTvDetail(tId);
      verify(() => mockRemoteDataSource.getTvDetail(tId));
      expect(
        result,
        equals(Left(ConnectionFailure('Failed to connect to the network'))),
      );
    });
  });

  group('Get Tv Recommendations', () {
    final tTvList = <TvModel>[];
    final tId = 1;

    test('should return data (tv list) when the call is successful', () async {
      when(() => mockRemoteDataSource.getTvRecommendations(tId))
          .thenAnswer((_) async => tTvList);
      final result = await repository.getTvRecommendations(tId);
      verify(() => mockRemoteDataSource.getTvRecommendations(tId));
      final resultList = result.getOrElse(() => []);
      expect(resultList, equals(tTvList));
    });

    test('should return server failure when call to remote data source is unsuccessful', () async {
      when(() => mockRemoteDataSource.getTvRecommendations(tId))
          .thenThrow(ServerException());
      final result = await repository.getTvRecommendations(tId);
      verify(() => mockRemoteDataSource.getTvRecommendations(tId));
      expect(result, equals(Left(ServerFailure(''))));
    });

    test('should return connection failure when the device is not connected to the internet', () async {
      when(() => mockRemoteDataSource.getTvRecommendations(tId))
          .thenThrow(SocketException('Failed to connect to the network'));
      final result = await repository.getTvRecommendations(tId);
      verify(() => mockRemoteDataSource.getTvRecommendations(tId));
      expect(
        result,
        equals(Left(ConnectionFailure('Failed to connect to the network'))),
      );
    });
  });

  group('Search Tv', () {
    final tQuery = 'game of thrones';

    test(
      'should return tv list when call to data source is successful',
      () async {
        when(() => mockRemoteDataSource.searchTv(tQuery))
            .thenAnswer((_) async => tTvModelList);
        final result = await repository.searchTv(tQuery);
        final resultList = result.getOrElse(() => []);
        expect(resultList, tTvList);
      },
    );

    test(
      'should return ServerFailure when call to data source is unsuccessful',
      () async {
        when(() => mockRemoteDataSource.searchTv(tQuery))
            .thenThrow(ServerException());
        final result = await repository.searchTv(tQuery);
        expect(result, Left(ServerFailure('')));
      },
    );

    test('should return ConnectionFailure when device is not connected to the internet', () async {
      when(() => mockRemoteDataSource.searchTv(tQuery))
          .thenThrow(SocketException('Failed to connect to the network'));
      final result = await repository.searchTv(tQuery);
      expect(
        result,
        Left(ConnectionFailure('Failed to connect to the network')),
      );
    });
  });

  group('save watchlist', () {
    test('should return success message when saving successful', () async {
      when(() => mockLocalDataSource.insertWatchlistTv(testTvTable))
          .thenAnswer((_) async => 'Added to Watchlist');
      final result = await repository.saveWatchlistTv(testTvDetail);
      expect(result, Right('Added to Watchlist'));
    });

    test('should return DatabaseFailure when saving unsuccessful', () async {
      when(() => mockLocalDataSource.insertWatchlistTv(testTvTable))
          .thenThrow(DatabaseException('Failed to add watchlist'));
      final result = await repository.saveWatchlistTv(testTvDetail);
      expect(result, Left(DatabaseFailure('Failed to add watchlist')));
    });
  });

  group('remove watchlist', () {
    test('should return success message when remove successful', () async {
      when(() => mockLocalDataSource.removeWatchlistTv(testTvTable))
          .thenAnswer((_) async => 'Removed from Watchlist');
      final result = await repository.removeWatchlistTv(testTvDetail);
      expect(result, Right('Removed from Watchlist'));
    });

    test('should return DatabaseFailure when remove unsuccessful', () async {
      when(() => mockLocalDataSource.removeWatchlistTv(testTvTable))
          .thenThrow(DatabaseException('Failed to remove watchlist'));
      final result = await repository.removeWatchlistTv(testTvDetail);
      expect(result, Left(DatabaseFailure('Failed to remove watchlist')));
    });
  });

  group('get watchlist status', () {
    test('should return watch status whether data is found', () async {
      final tId = 1;
      when(() => mockLocalDataSource.getTvById(tId))
          .thenAnswer((_) async => null);
      final result = await repository.isAddedToWatchlistTv(tId);
      expect(result, false);
    });
  });

  group('get watchlist tv', () {
    test('should return list of Tv', () async {
      when(() => mockLocalDataSource.getWatchlistTv())
          .thenAnswer((_) async => [testTvTable]);
      final result = await repository.getWatchlistTv();
      final resultList = result.getOrElse(() => []);
      expect(resultList, [testWatchlistTv]);
    });
  });

  group('Get Tv Season Detail', () {
    const tTvId = 1;
    const tSeasonNumber = 1;
    const tSeasonResponse = SeasonDetailResponse(
      id: 3624,
      name: 'Season 1',
      seasonNumber: 1,
      overview: 'season overview',
      posterPath: '/season1.jpg',
      airDate: '2011-04-17',
      episodes: [
        EpisodeModel(
          id: 63056,
          name: 'Winter Is Coming',
          episodeNumber: 1,
          overview: 'overview',
          stillPath: '/still.jpg',
          airDate: '2011-04-17',
          runtime: 62,
          voteAverage: 8.2,
        ),
      ],
    );

    test('should return season detail when the call to remote data source is successful', () async {
      when(() => mockRemoteDataSource.getTvSeasonDetail(tTvId, tSeasonNumber))
          .thenAnswer((_) async => tSeasonResponse);
      final result = await repository.getTvSeasonDetail(tTvId, tSeasonNumber);
      verify(
        () => mockRemoteDataSource.getTvSeasonDetail(tTvId, tSeasonNumber),
      );
      expect(result, equals(Right(testSeasonDetail)));
    });

    test('should return Server Failure when the call to remote data source is unsuccessful', () async {
      when(() => mockRemoteDataSource.getTvSeasonDetail(tTvId, tSeasonNumber))
          .thenThrow(ServerException());
      final result = await repository.getTvSeasonDetail(tTvId, tSeasonNumber);
      expect(result, equals(Left(ServerFailure(''))));
    });

    test('should return connection failure when the device is not connected to internet', () async {
      when(() => mockRemoteDataSource.getTvSeasonDetail(tTvId, tSeasonNumber))
          .thenThrow(SocketException('Failed to connect to the network'));
      final result = await repository.getTvSeasonDetail(tTvId, tSeasonNumber);
      expect(
        result,
        equals(Left(ConnectionFailure('Failed to connect to the network'))),
      );
    });
  });
}
