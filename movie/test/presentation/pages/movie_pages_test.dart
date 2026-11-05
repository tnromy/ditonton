import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/movie.dart';

import '../../dummy_data/dummy_objects.dart';

class MockNowPlayingMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements NowPlayingMoviesBloc {}

class MockPopularMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements PopularMoviesBloc {}

class MockTopRatedMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements TopRatedMoviesBloc {}

class MockWatchlistMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements WatchlistMoviesBloc {}

class MockMovieDetailBloc extends MockBloc<FetchMovieDetail, MovieDetailState>
    implements MovieDetailBloc {}

class MockMovieRecommendationsBloc
    extends MockBloc<FetchMovieRecommendations, MovieListState>
    implements MovieRecommendationsBloc {}

class MockMovieWatchlistBloc
    extends MockBloc<MovieWatchlistEvent, MovieWatchlistState>
    implements MovieWatchlistBloc {}

class MockSearchMoviesBloc extends MockBloc<OnMovieQueryChanged, MovieListState>
    implements SearchMoviesBloc {}

void main() {
  late MockNowPlayingMoviesBloc nowPlaying;
  late MockPopularMoviesBloc popular;
  late MockTopRatedMoviesBloc topRated;
  late MockWatchlistMoviesBloc watchlist;
  late MockMovieDetailBloc detail;
  late MockMovieRecommendationsBloc recommendations;
  late MockMovieWatchlistBloc watchlistStatus;
  late MockSearchMoviesBloc search;
  late List<RouteSettings> pushed;

  setUpAll(() {
    registerFallbackValue(const FetchMovies());
    registerFallbackValue(const FetchMovieDetail(0));
    registerFallbackValue(const FetchMovieRecommendations(0));
    registerFallbackValue(const LoadMovieWatchlistStatus(0));
    registerFallbackValue(const OnMovieQueryChanged(''));
  });

  setUp(() {
    nowPlaying = MockNowPlayingMoviesBloc();
    popular = MockPopularMoviesBloc();
    topRated = MockTopRatedMoviesBloc();
    watchlist = MockWatchlistMoviesBloc();
    detail = MockMovieDetailBloc();
    recommendations = MockMovieRecommendationsBloc();
    watchlistStatus = MockMovieWatchlistBloc();
    search = MockSearchMoviesBloc();
    pushed = [];

    for (final bloc in [nowPlaying, popular, topRated, watchlist, search]) {
      when(() => bloc.state).thenReturn(const MovieListEmpty());
    }
    when(() => detail.state).thenReturn(const MovieDetailEmpty());
    when(() => recommendations.state).thenReturn(const MovieListEmpty());
    when(() => watchlistStatus.state).thenReturn(const MovieWatchlistState());
  });

  Widget makeTestable(Widget body) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NowPlayingMoviesBloc>.value(value: nowPlaying),
        BlocProvider<PopularMoviesBloc>.value(value: popular),
        BlocProvider<TopRatedMoviesBloc>.value(value: topRated),
        BlocProvider<WatchlistMoviesBloc>.value(value: watchlist),
        BlocProvider<MovieDetailBloc>.value(value: detail),
        BlocProvider<MovieRecommendationsBloc>.value(value: recommendations),
        BlocProvider<MovieWatchlistBloc>.value(value: watchlistStatus),
        BlocProvider<SearchMoviesBloc>.value(value: search),
      ],
      child: MaterialApp(
        home: body,
        onGenerateRoute: (settings) {
          pushed.add(settings);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(body: Text('route ${settings.name}')),
          );
        },
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  group('HomeMoviePage', () {
    testWidgets('should fetch the three movie lists on start', (tester) async {
      await tester.pumpWidget(makeTestable(HomeMoviePage()));

      for (final bloc in <MovieListBloc>[nowPlaying, popular, topRated]) {
        verify(() => bloc.add(const FetchMovies())).called(1);
      }
    });

    testWidgets('should show posters, spinner and error per section', (
      tester,
    ) async {
      when(() => nowPlaying.state).thenReturn(MovieListHasData(testMovieList));
      when(() => popular.state).thenReturn(const MovieListLoading());
      when(() => topRated.state).thenReturn(const MovieListError('Failed'));

      await tester.pumpWidget(makeTestable(HomeMoviePage()));

      expect(find.text('Now Playing'), findsOneWidget);
      expect(find.byKey(const Key('movie_poster_557')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('Failed'), findsOneWidget);
    });

    for (final (index, route) in [
      (0, popularMoviesRoute),
      (1, topRatedMoviesRoute),
    ]) {
      testWidgets('See More #$index should open $route', (tester) async {
        await tester.pumpWidget(makeTestable(HomeMoviePage()));
        await tester.tap(find.text('See More').at(index));
        await settle(tester);

        expect(pushed.last.name, route);
      });
    }

    testWidgets('search action and poster tap should navigate', (tester) async {
      when(() => nowPlaying.state).thenReturn(MovieListHasData(testMovieList));
      await tester.pumpWidget(makeTestable(HomeMoviePage()));

      await tester.tap(find.byKey(const Key('movie_poster_557')));
      await settle(tester);
      expect(pushed.last.name, movieDetailRoute);
      expect(pushed.last.arguments, 557);

      Navigator.of(tester.element(find.text('route $movieDetailRoute'))).pop();
      await settle(tester);
      await tester.tap(find.byTooltip('Search movies'));
      await settle(tester);
      expect(pushed.last.name, searchMoviesRoute);
    });
  });

  for (final (name, page, bloc) in [
    ('PopularMoviesPage', PopularMoviesPage(), () => popular as MovieListBloc),
    (
      'TopRatedMoviesPage',
      TopRatedMoviesPage(),
      () => topRated as MovieListBloc,
    ),
  ]) {
    group(name, () {
      testWidgets('should fetch movies and show a spinner while loading', (
        tester,
      ) async {
        when(() => bloc().state).thenReturn(const MovieListLoading());
        await tester.pumpWidget(makeTestable(page));

        verify(() => bloc().add(const FetchMovies())).called(1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should list movie cards and open the detail on tap', (
        tester,
      ) async {
        when(() => bloc().state).thenReturn(MovieListHasData(testMovieList));
        await tester.pumpWidget(makeTestable(page));

        expect(find.byType(MovieCard), findsOneWidget);
        expect(find.text('Spider-Man'), findsOneWidget);

        await tester.tap(find.byType(MovieCard));
        await settle(tester);
        expect(pushed.last.name, movieDetailRoute);
      });

      testWidgets('should show the error message', (tester) async {
        when(() => bloc().state).thenReturn(const MovieListError('Oops'));
        await tester.pumpWidget(makeTestable(page));

        expect(find.byKey(const Key('error_message')), findsOneWidget);
        expect(find.text('Oops'), findsOneWidget);
      });
    });
  }

  group('SearchMoviesPage', () {
    testWidgets('typing should dispatch the query', (tester) async {
      await tester.pumpWidget(makeTestable(SearchMoviesPage()));
      await tester.enterText(find.byType(TextField), 'spiderman');

      verify(() => search.add(const OnMovieQueryChanged('spiderman')))
          .called(1);
    });

    testWidgets('should show results, empty message and spinner', (
      tester,
    ) async {
      when(() => search.state).thenReturn(MovieListHasData(testMovieList));
      await tester.pumpWidget(makeTestable(SearchMoviesPage()));
      expect(find.byType(MovieCard), findsOneWidget);

      when(() => search.state).thenReturn(const MovieListHasData(<Movie>[]));
      await tester.pumpWidget(
        makeTestable(const SearchMoviesPage(key: Key('b'))),
      );
      expect(find.text('No movie found'), findsOneWidget);

      when(() => search.state).thenReturn(const MovieListLoading());
      await tester.pumpWidget(
        makeTestable(const SearchMoviesPage(key: Key('c'))),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('WatchlistMoviesView', () {
    testWidgets('should list watchlisted movies or an empty message', (
      tester,
    ) async {
      when(() => watchlist.state)
          .thenReturn(MovieListHasData([testWatchlistMovie]));
      await tester.pumpWidget(
        makeTestable(Scaffold(body: WatchlistMoviesView())),
      );
      expect(find.byType(MovieCard), findsOneWidget);

      when(() => watchlist.state).thenReturn(const MovieListHasData(<Movie>[]));
      await tester.pumpWidget(
        makeTestable(const Scaffold(body: WatchlistMoviesView(key: Key('e')))),
      );
      expect(find.text('No movie in your watchlist yet'), findsOneWidget);
    });
  });

  group('MovieDetailPage', () {
    testWidgets('should request detail, recommendations and status', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable(MovieDetailPage(id: 1)));

      verify(() => detail.add(const FetchMovieDetail(1))).called(1);
      verify(() => recommendations.add(const FetchMovieRecommendations(1)))
          .called(1);
      verify(() => watchlistStatus.add(const LoadMovieWatchlistStatus(1)))
          .called(1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show the error message', (tester) async {
      when(() => detail.state).thenReturn(const MovieDetailError('Not found'));
      await tester.pumpWidget(makeTestable(const MovieDetailPage(id: 1)));

      expect(find.text('Not found'), findsOneWidget);
    });

    testWidgets('should show the movie detail and recommendations', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(MovieDetailHasData(testMovieDetail));
      when(() => recommendations.state)
          .thenReturn(MovieListHasData(testMovieList));
      await tester.pumpWidget(makeTestable(const MovieDetailPage(id: 1)));

      expect(find.text('title'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('2h 0m'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('movie_poster_557')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('movie_poster_557')));
      await settle(tester);
      expect(pushed.last.name, movieDetailRoute);
      expect(pushed.last.arguments, 557);
    });

    testWidgets('should show recommendation states', (tester) async {
      when(() => detail.state).thenReturn(MovieDetailHasData(testMovieDetail));
      when(() => recommendations.state).thenReturn(const MovieListError('x'));
      await tester.pumpWidget(makeTestable(const MovieDetailPage(id: 1)));
      expect(find.text('x'), findsOneWidget);

      when(() => recommendations.state)
          .thenReturn(const MovieListHasData(<Movie>[]));
      await tester.pumpWidget(
        makeTestable(const MovieDetailPage(key: Key('2'), id: 2)),
      );
      expect(find.text('No recommendations'), findsOneWidget);
    });

    testWidgets('watchlist button should add or remove the movie', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(MovieDetailHasData(testMovieDetail));
      await tester.pumpWidget(makeTestable(const MovieDetailPage(id: 1)));

      await tester.tap(find.byType(FilledButton));
      verify(() => watchlistStatus.add(AddMovieToWatchlist(testMovieDetail)))
          .called(1);

      when(() => watchlistStatus.state)
          .thenReturn(const MovieWatchlistState(isAdded: true));
      await tester.pumpWidget(
        makeTestable(const MovieDetailPage(key: Key('3'), id: 3)),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      verify(
        () => watchlistStatus.add(RemoveMovieFromWatchlist(testMovieDetail)),
      ).called(1);
    });

    testWidgets('should show a snackbar for a successful watchlist change', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(MovieDetailHasData(testMovieDetail));
      whenListen(
        watchlistStatus,
        Stream.value(
          const MovieWatchlistState(
            isAdded: true,
            message: MovieWatchlistBloc.addSuccessMessage,
          ),
        ),
        initialState: const MovieWatchlistState(),
      );
      await tester.pumpWidget(makeTestable(const MovieDetailPage(id: 1)));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Added to Watchlist'), findsOneWidget);
    });

    testWidgets('should show a dialog when the watchlist change fails', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(MovieDetailHasData(testMovieDetail));
      whenListen(
        watchlistStatus,
        Stream.value(const MovieWatchlistState(message: 'Database error')),
        initialState: const MovieWatchlistState(),
      );
      await tester.pumpWidget(makeTestable(const MovieDetailPage(id: 1)));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Database error'), findsOneWidget);
    });

    testWidgets('back button should close the page', (tester) async {
      when(() => detail.state).thenReturn(MovieDetailHasData(testMovieDetail));
      await tester.pumpWidget(
        makeTestable(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieDetailPage(id: 1)),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await settle(tester);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await settle(tester);

      expect(find.text('open'), findsOneWidget);
    });

    test('duration should format hours and minutes', () {
      expect(MovieDetailContent.showDuration(45), '45m');
      expect(MovieDetailContent.showDuration(125), '2h 5m');
    });
  });
}
