import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/movie.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  const serverFailure = ServerFailure('Server Failure');

  group('MovieListBloc subclasses', () {
    final nowPlaying = MockGetNowPlayingMovies();
    final popular = MockGetPopularMovies();
    final topRated = MockGetTopRatedMovies();
    final watchlist = MockGetWatchlistMovies();

    final cases =
        <
          String,
          (
            MovieListBloc Function(),
            void Function(Either<Failure, List<Movie>>),
          )
        >{
          'NowPlayingMoviesBloc': (
            () => NowPlayingMoviesBloc(nowPlaying),
            (r) => when(nowPlaying.execute).thenAnswer((_) async => r),
          ),
          'PopularMoviesBloc': (
            () => PopularMoviesBloc(popular),
            (r) => when(popular.execute).thenAnswer((_) async => r),
          ),
          'TopRatedMoviesBloc': (
            () => TopRatedMoviesBloc(topRated),
            (r) => when(topRated.execute).thenAnswer((_) async => r),
          ),
          'WatchlistMoviesBloc': (
            () => WatchlistMoviesBloc(watchlist),
            (r) => when(watchlist.execute).thenAnswer((_) async => r),
          ),
        };

    cases.forEach((name, testCase) {
      final (create, stub) = testCase;

      group(name, () {
        test('initial state should be empty', () {
          expect(create().state, const MovieListEmpty());
        });

        blocTest<MovieListBloc, MovieListState>(
          'should emit [Loading, HasData] when data is gotten successfully',
          setUp: () => stub(Right(testMovieList)),
          build: create,
          act: (bloc) => bloc.add(const FetchMovies()),
          expect: () => [
            const MovieListLoading(),
            MovieListHasData(testMovieList),
          ],
        );

        blocTest<MovieListBloc, MovieListState>(
          'should emit [Loading, Error] when getting data is unsuccessful',
          setUp: () => stub(const Left(serverFailure)),
          build: create,
          act: (bloc) => bloc.add(const FetchMovies()),
          expect: () => [
            const MovieListLoading(),
            const MovieListError('Server Failure'),
          ],
        );
      });
    });
  });

  group('MovieRecommendationsBloc', () {
    late MockGetMovieRecommendations usecase;
    setUp(() => usecase = MockGetMovieRecommendations());

    blocTest<MovieRecommendationsBloc, MovieListState>(
      'should emit [Loading, HasData] with recommendations',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => Right(testMovieList)),
      build: () => MovieRecommendationsBloc(usecase),
      act: (bloc) => bloc.add(const FetchMovieRecommendations(1)),
      expect: () => [const MovieListLoading(), MovieListHasData(testMovieList)],
    );

    blocTest<MovieRecommendationsBloc, MovieListState>(
      'should emit [Loading, Error] when unsuccessful',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => const Left(serverFailure)),
      build: () => MovieRecommendationsBloc(usecase),
      act: (bloc) => bloc.add(const FetchMovieRecommendations(1)),
      expect: () => [
        const MovieListLoading(),
        const MovieListError('Server Failure'),
      ],
    );

    test('event should compare by id', () {
      expect(
        const FetchMovieRecommendations(1),
        const FetchMovieRecommendations(1),
      );
    });
  });

  group('MovieDetailBloc', () {
    late MockGetMovieDetail usecase;
    setUp(() => usecase = MockGetMovieDetail());

    test('initial state should be empty', () {
      expect(MovieDetailBloc(usecase).state, const MovieDetailEmpty());
    });

    blocTest<MovieDetailBloc, MovieDetailState>(
      'should emit [Loading, HasData] when detail is gotten successfully',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => Right(testMovieDetail)),
      build: () => MovieDetailBloc(usecase),
      act: (bloc) => bloc.add(const FetchMovieDetail(1)),
      expect: () => [
        const MovieDetailLoading(),
        MovieDetailHasData(testMovieDetail),
      ],
    );

    blocTest<MovieDetailBloc, MovieDetailState>(
      'should emit [Loading, Error] when getting detail is unsuccessful',
      setUp: () =>
          when(() => usecase.execute(1))
              .thenAnswer((_) async => const Left(serverFailure)),
      build: () => MovieDetailBloc(usecase),
      act: (bloc) => bloc.add(const FetchMovieDetail(1)),
      expect: () => [
        const MovieDetailLoading(),
        const MovieDetailError('Server Failure'),
      ],
    );
  });

  group('MovieWatchlistBloc', () {
    late MockGetWatchListStatus getStatus;
    late MockSaveWatchlist save;
    late MockRemoveWatchlist remove;

    setUp(() {
      getStatus = MockGetWatchListStatus();
      save = MockSaveWatchlist();
      remove = MockRemoveWatchlist();
    });

    MovieWatchlistBloc build() => MovieWatchlistBloc(
      getWatchListStatus: getStatus,
      saveWatchlist: save,
      removeWatchlist: remove,
    );

    test('initial state should not be added', () {
      expect(build().state, const MovieWatchlistState());
    });

    blocTest<MovieWatchlistBloc, MovieWatchlistState>(
      'should load the watchlist status',
      setUp: () =>
          when(() => getStatus.execute(1)).thenAnswer((_) async => true),
      build: build,
      act: (bloc) => bloc.add(const LoadMovieWatchlistStatus(1)),
      expect: () => [const MovieWatchlistState(isAdded: true)],
    );

    blocTest<MovieWatchlistBloc, MovieWatchlistState>(
      'should save to watchlist and emit the success message',
      setUp: () {
        when(() => save.execute(testMovieDetail))
            .thenAnswer((_) async => const Right('Added to Watchlist'));
        when(() => getStatus.execute(1)).thenAnswer((_) async => true);
      },
      build: build,
      act: (bloc) => bloc.add(AddMovieToWatchlist(testMovieDetail)),
      expect: () => [
        const MovieWatchlistState(
          isAdded: true,
          message: MovieWatchlistBloc.addSuccessMessage,
        ),
      ],
      verify: (_) => verify(() => save.execute(testMovieDetail)).called(1),
    );

    blocTest<MovieWatchlistBloc, MovieWatchlistState>(
      'should remove from watchlist and clear the previous message first',
      seed: () => const MovieWatchlistState(
        isAdded: true,
        message: MovieWatchlistBloc.addSuccessMessage,
      ),
      setUp: () {
        when(() => remove.execute(testMovieDetail))
            .thenAnswer((_) async => const Right('Removed from Watchlist'));
        when(() => getStatus.execute(1)).thenAnswer((_) async => false);
      },
      build: build,
      act: (bloc) => bloc.add(RemoveMovieFromWatchlist(testMovieDetail)),
      expect: () => [
        const MovieWatchlistState(isAdded: true),
        const MovieWatchlistState(
          message: MovieWatchlistBloc.removeSuccessMessage,
        ),
      ],
    );

    blocTest<MovieWatchlistBloc, MovieWatchlistState>(
      'should emit the failure message when saving fails',
      setUp: () {
        when(() => save.execute(testMovieDetail))
            .thenAnswer((_) async => const Left(DatabaseFailure('Failed')));
        when(() => getStatus.execute(1)).thenAnswer((_) async => false);
      },
      build: build,
      act: (bloc) => bloc.add(AddMovieToWatchlist(testMovieDetail)),
      expect: () => [const MovieWatchlistState(message: 'Failed')],
    );

    test('events should compare by their values', () {
      expect(
        const LoadMovieWatchlistStatus(1),
        const LoadMovieWatchlistStatus(1),
      );
      expect(
        AddMovieToWatchlist(testMovieDetail).props,
        RemoveMovieFromWatchlist(testMovieDetail).props,
      );
    });
  });

  group('SearchMoviesBloc', () {
    late MockSearchMovies usecase;
    const query = 'spiderman';
    setUp(() => usecase = MockSearchMovies());

    blocTest<SearchMoviesBloc, MovieListState>(
      'should emit [Loading, HasData] after the debounce time',
      setUp: () =>
          when(() => usecase.execute(query))
              .thenAnswer((_) async => Right(testMovieList)),
      build: () => SearchMoviesBloc(usecase),
      act: (bloc) => bloc.add(const OnMovieQueryChanged(query)),
      wait:
          SearchMoviesBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [const MovieListLoading(), MovieListHasData(testMovieList)],
    );

    blocTest<SearchMoviesBloc, MovieListState>(
      'should emit [Loading, Error] when the search fails',
      setUp: () =>
          when(() => usecase.execute(query))
              .thenAnswer((_) async => const Left(serverFailure)),
      build: () => SearchMoviesBloc(usecase),
      act: (bloc) => bloc.add(const OnMovieQueryChanged(query)),
      wait:
          SearchMoviesBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [
        const MovieListLoading(),
        const MovieListError('Server Failure'),
      ],
    );

    blocTest<SearchMoviesBloc, MovieListState>(
      'should only search the latest query typed within the debounce time',
      setUp: () =>
          when(() => usecase.execute(query))
              .thenAnswer((_) async => Right(testMovieList)),
      build: () => SearchMoviesBloc(usecase),
      act: (bloc) => bloc
        ..add(const OnMovieQueryChanged('spi'))
        ..add(const OnMovieQueryChanged(query)),
      wait:
          SearchMoviesBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [const MovieListLoading(), MovieListHasData(testMovieList)],
      verify: (_) => verifyNever(() => usecase.execute('spi')),
    );

    blocTest<SearchMoviesBloc, MovieListState>(
      'should emit Empty without searching for a blank query',
      seed: () => MovieListHasData(testMovieList),
      build: () => SearchMoviesBloc(usecase),
      act: (bloc) => bloc.add(const OnMovieQueryChanged('   ')),
      wait:
          SearchMoviesBloc.debounceDuration + const Duration(milliseconds: 100),
      expect: () => [const MovieListEmpty()],
      verify: (_) => verifyZeroInteractions(usecase),
    );
  });
}
