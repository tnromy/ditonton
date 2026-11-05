import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:tv/tv.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  const serverFailure = ServerFailure('Server Failure');

  group('TvListBloc subclasses', () {
    final onTheAir = MockGetOnTheAirTv();
    final popular = MockGetPopularTv();
    final topRated = MockGetTopRatedTv();
    final watchlist = MockGetWatchlistTv();

    final cases =
        <
          String,
          (TvListBloc Function(), void Function(Either<Failure, List<Tv>>))
        >{
          'OnTheAirTvBloc': (
            () => OnTheAirTvBloc(onTheAir),
            (r) => when(onTheAir.execute).thenAnswer((_) async => r),
          ),
          'PopularTvBloc': (
            () => PopularTvBloc(popular),
            (r) => when(popular.execute).thenAnswer((_) async => r),
          ),
          'TopRatedTvBloc': (
            () => TopRatedTvBloc(topRated),
            (r) => when(topRated.execute).thenAnswer((_) async => r),
          ),
          'WatchlistTvBloc': (
            () => WatchlistTvBloc(watchlist),
            (r) => when(watchlist.execute).thenAnswer((_) async => r),
          ),
        };

    cases.forEach((name, testCase) {
      final (create, stub) = testCase;

      group(name, () {
        test('initial state should be empty', () {
          expect(create().state, const TvListEmpty());
        });

        blocTest<TvListBloc, TvListState>(
          'should emit [Loading, HasData] when data is gotten successfully',
          setUp: () => stub(Right(testTvList)),
          build: create,
          act: (bloc) => bloc.add(const FetchTv()),
          expect: () => [const TvListLoading(), TvListHasData(testTvList)],
        );

        blocTest<TvListBloc, TvListState>(
          'should emit [Loading, Error] when getting data is unsuccessful',
          setUp: () => stub(const Left(serverFailure)),
          build: create,
          act: (bloc) => bloc.add(const FetchTv()),
          expect: () => [
            const TvListLoading(),
            const TvListError('Server Failure'),
          ],
        );
      });
    });
  });

  group('TvRecommendationsBloc', () {
    late MockGetTvRecommendations usecase;
    setUp(() => usecase = MockGetTvRecommendations());

    blocTest<TvRecommendationsBloc, TvListState>(
      'should emit [Loading, HasData] with recommendations',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => Right(testTvList)),
      build: () => TvRecommendationsBloc(usecase),
      act: (bloc) => bloc.add(const FetchTvRecommendations(1)),
      expect: () => [const TvListLoading(), TvListHasData(testTvList)],
    );

    blocTest<TvRecommendationsBloc, TvListState>(
      'should emit [Loading, Error] when unsuccessful',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => const Left(serverFailure)),
      build: () => TvRecommendationsBloc(usecase),
      act: (bloc) => bloc.add(const FetchTvRecommendations(1)),
      expect: () => [
        const TvListLoading(),
        const TvListError('Server Failure'),
      ],
    );

    test('event should compare by id', () {
      expect(const FetchTvRecommendations(1), const FetchTvRecommendations(1));
    });
  });

  group('TvDetailBloc', () {
    late MockGetTvDetail usecase;
    setUp(() => usecase = MockGetTvDetail());

    test('initial state should be empty', () {
      expect(TvDetailBloc(usecase).state, const TvDetailEmpty());
    });

    blocTest<TvDetailBloc, TvDetailState>(
      'should emit [Loading, HasData] when detail is gotten successfully',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => Right(testTvDetail)),
      build: () => TvDetailBloc(usecase),
      act: (bloc) => bloc.add(const FetchTvDetail(1)),
      expect: () => [const TvDetailLoading(), TvDetailHasData(testTvDetail)],
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'should emit [Loading, Error] when getting detail is unsuccessful',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => const Left(serverFailure)),
      build: () => TvDetailBloc(usecase),
      act: (bloc) => bloc.add(const FetchTvDetail(1)),
      expect: () => [
        const TvDetailLoading(),
        const TvDetailError('Server Failure'),
      ],
    );
  });

  group('TvWatchlistBloc', () {
    late MockGetWatchlistStatusTv getStatus;
    late MockSaveWatchlistTv save;
    late MockRemoveWatchlistTv remove;

    setUp(() {
      getStatus = MockGetWatchlistStatusTv();
      save = MockSaveWatchlistTv();
      remove = MockRemoveWatchlistTv();
    });

    TvWatchlistBloc build() => TvWatchlistBloc(
      getWatchlistStatus: getStatus,
      saveWatchlist: save,
      removeWatchlist: remove,
    );

    test('initial state should not be added', () {
      expect(build().state, const TvWatchlistState());
    });

    blocTest<TvWatchlistBloc, TvWatchlistState>(
      'should load the watchlist status',
      setUp: () =>
          when(() => getStatus.execute(1)).thenAnswer((_) async => true),
      build: build,
      act: (bloc) => bloc.add(const LoadTvWatchlistStatus(1)),
      expect: () => [const TvWatchlistState(isAdded: true)],
    );

    blocTest<TvWatchlistBloc, TvWatchlistState>(
      'should save to watchlist and emit the success message',
      setUp: () {
        when(() => save.execute(testTvDetail))
            .thenAnswer((_) async => const Right('Added to Watchlist'));
        when(() => getStatus.execute(1)).thenAnswer((_) async => true);
      },
      build: build,
      act: (bloc) => bloc.add(AddTvToWatchlist(testTvDetail)),
      expect: () => [
        const TvWatchlistState(
          isAdded: true,
          message: TvWatchlistBloc.addSuccessMessage,
        ),
      ],
      verify: (_) => verify(() => save.execute(testTvDetail)).called(1),
    );

    blocTest<TvWatchlistBloc, TvWatchlistState>(
      'should remove from watchlist and clear the previous message first',
      seed: () => const TvWatchlistState(
        isAdded: true,
        message: TvWatchlistBloc.addSuccessMessage,
      ),
      setUp: () {
        when(() => remove.execute(testTvDetail))
            .thenAnswer((_) async => const Right('Removed from Watchlist'));
        when(() => getStatus.execute(1)).thenAnswer((_) async => false);
      },
      build: build,
      act: (bloc) => bloc.add(RemoveTvFromWatchlist(testTvDetail)),
      expect: () => [
        const TvWatchlistState(isAdded: true),
        const TvWatchlistState(message: TvWatchlistBloc.removeSuccessMessage),
      ],
    );

    blocTest<TvWatchlistBloc, TvWatchlistState>(
      'should emit the failure message when saving fails',
      setUp: () {
        when(() => save.execute(testTvDetail))
            .thenAnswer((_) async => const Left(DatabaseFailure('Failed')));
        when(() => getStatus.execute(1)).thenAnswer((_) async => false);
      },
      build: build,
      act: (bloc) => bloc.add(AddTvToWatchlist(testTvDetail)),
      expect: () => [const TvWatchlistState(message: 'Failed')],
    );

    test('events should compare by their values', () {
      expect(const LoadTvWatchlistStatus(1), const LoadTvWatchlistStatus(1));
      expect(
        AddTvToWatchlist(testTvDetail).props,
        RemoveTvFromWatchlist(testTvDetail).props,
      );
    });
  });

  group('SearchTvBloc', () {
    late MockSearchTv usecase;
    const query = 'game of thrones';
    setUp(() => usecase = MockSearchTv());

    blocTest<SearchTvBloc, TvListState>(
      'should emit [Loading, HasData] after the debounce time',
      setUp: () =>
          when(() => usecase.execute(query))
              .thenAnswer((_) async => Right(testTvList)),
      build: () => SearchTvBloc(usecase),
      act: (bloc) => bloc.add(const OnTvQueryChanged(query)),
      wait: SearchTvBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [const TvListLoading(), TvListHasData(testTvList)],
    );

    blocTest<SearchTvBloc, TvListState>(
      'should emit [Loading, Error] when the search fails',
      setUp: () =>
          when(() => usecase.execute(query))
              .thenAnswer((_) async => const Left(serverFailure)),
      build: () => SearchTvBloc(usecase),
      act: (bloc) => bloc.add(const OnTvQueryChanged(query)),
      wait: SearchTvBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [
        const TvListLoading(),
        const TvListError('Server Failure'),
      ],
    );

    blocTest<SearchTvBloc, TvListState>(
      'should only search the latest query typed within the debounce time',
      setUp: () =>
          when(() => usecase.execute(query))
              .thenAnswer((_) async => Right(testTvList)),
      build: () => SearchTvBloc(usecase),
      act: (bloc) => bloc
        ..add(const OnTvQueryChanged('gam'))
        ..add(const OnTvQueryChanged(query)),
      wait: SearchTvBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [const TvListLoading(), TvListHasData(testTvList)],
      verify: (_) => verifyNever(() => usecase.execute('gam')),
    );

    blocTest<SearchTvBloc, TvListState>(
      'should emit Empty without searching for a blank query',
      seed: () => TvListHasData(testTvList),
      build: () => SearchTvBloc(usecase),
      act: (bloc) => bloc.add(const OnTvQueryChanged('   ')),
      wait: SearchTvBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [const TvListEmpty()],
      verify: (_) => verifyZeroInteractions(usecase),
    );
  });

  group('TvSeasonDetailBloc', () {
    late MockGetTvSeasonDetail usecase;
    setUp(() => usecase = MockGetTvSeasonDetail());

    test('initial state should be empty', () {
      expect(TvSeasonDetailBloc(usecase).state, const TvSeasonDetailEmpty());
    });

    blocTest<TvSeasonDetailBloc, TvSeasonDetailState>(
      'should emit [Loading, HasData] when the season is gotten successfully',
      setUp: () =>
          when(() => usecase.execute(1, 1))
              .thenAnswer((_) async => const Right(testSeasonDetail)),
      build: () => TvSeasonDetailBloc(usecase),
      act: (bloc) =>
          bloc.add(const FetchTvSeasonDetail(tvId: 1, seasonNumber: 1)),
      expect: () => [
        const TvSeasonDetailLoading(),
        const TvSeasonDetailHasData(testSeasonDetail),
      ],
    );

    blocTest<TvSeasonDetailBloc, TvSeasonDetailState>(
      'should emit [Loading, Error] when getting the season fails',
      setUp: () =>
          when(() => usecase.execute(1, 1))
              .thenAnswer((_) async => const Left(serverFailure)),
      build: () => TvSeasonDetailBloc(usecase),
      act: (bloc) =>
          bloc.add(const FetchTvSeasonDetail(tvId: 1, seasonNumber: 1)),
      expect: () => [
        const TvSeasonDetailLoading(),
        const TvSeasonDetailError('Server Failure'),
      ],
    );

    test('event should compare by tv id and season number', () {
      expect(
        const FetchTvSeasonDetail(tvId: 1, seasonNumber: 2),
        const FetchTvSeasonDetail(tvId: 1, seasonNumber: 2),
      );
    });
  });

  test('FetchTv should have no props', () {
    expect(FetchTv().props, isEmpty);
    expect(TvListEmpty().props, isEmpty);
  });
}
