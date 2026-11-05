import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv/domain/entities/episode.dart';
import 'package:tv/domain/entities/season.dart';
import 'package:tv/domain/entities/season_detail.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:tv/domain/entities/tv_detail.dart';
import 'package:tv/tv.dart';

import '../../dummy_data/dummy_objects.dart';

class MockOnTheAirTvBloc extends MockBloc<TvListEvent, TvListState>
    implements OnTheAirTvBloc {}

class MockPopularTvBloc extends MockBloc<TvListEvent, TvListState>
    implements PopularTvBloc {}

class MockTopRatedTvBloc extends MockBloc<TvListEvent, TvListState>
    implements TopRatedTvBloc {}

class MockWatchlistTvBloc extends MockBloc<TvListEvent, TvListState>
    implements WatchlistTvBloc {}

class MockTvDetailBloc extends MockBloc<FetchTvDetail, TvDetailState>
    implements TvDetailBloc {}

class MockTvRecommendationsBloc
    extends MockBloc<FetchTvRecommendations, TvListState>
    implements TvRecommendationsBloc {}

class MockTvWatchlistBloc extends MockBloc<TvWatchlistEvent, TvWatchlistState>
    implements TvWatchlistBloc {}

class MockSearchTvBloc extends MockBloc<OnTvQueryChanged, TvListState>
    implements SearchTvBloc {}

class MockTvSeasonDetailBloc
    extends MockBloc<FetchTvSeasonDetail, TvSeasonDetailState>
    implements TvSeasonDetailBloc {}

extension on TvDetail {
  TvDetail copyWithSeasons(List<Season> seasons) => TvDetail(
    backdropPath: backdropPath,
    genres: genres,
    id: id,
    originalName: originalName,
    overview: overview,
    posterPath: posterPath,
    firstAirDate: firstAirDate,
    name: name,
    numberOfEpisodes: numberOfEpisodes,
    numberOfSeasons: numberOfSeasons,
    seasons: seasons,
    voteAverage: voteAverage,
    voteCount: voteCount,
  );
}

void main() {
  late MockOnTheAirTvBloc onTheAir;
  late MockPopularTvBloc popular;
  late MockTopRatedTvBloc topRated;
  late MockWatchlistTvBloc watchlist;
  late MockTvDetailBloc detail;
  late MockTvRecommendationsBloc recommendations;
  late MockTvWatchlistBloc watchlistStatus;
  late MockSearchTvBloc search;
  late MockTvSeasonDetailBloc season;
  late List<RouteSettings> pushed;

  setUpAll(() {
    registerFallbackValue(const FetchTv());
    registerFallbackValue(const FetchTvDetail(0));
    registerFallbackValue(const FetchTvRecommendations(0));
    registerFallbackValue(const LoadTvWatchlistStatus(0));
    registerFallbackValue(const OnTvQueryChanged(''));
    registerFallbackValue(const FetchTvSeasonDetail(tvId: 0, seasonNumber: 0));
  });

  setUp(() {
    onTheAir = MockOnTheAirTvBloc();
    popular = MockPopularTvBloc();
    topRated = MockTopRatedTvBloc();
    watchlist = MockWatchlistTvBloc();
    detail = MockTvDetailBloc();
    recommendations = MockTvRecommendationsBloc();
    watchlistStatus = MockTvWatchlistBloc();
    search = MockSearchTvBloc();
    season = MockTvSeasonDetailBloc();
    when(() => season.state).thenReturn(const TvSeasonDetailEmpty());
    pushed = [];

    for (final bloc in [onTheAir, popular, topRated, watchlist, search]) {
      when(() => bloc.state).thenReturn(const TvListEmpty());
    }
    when(() => detail.state).thenReturn(const TvDetailEmpty());
    when(() => recommendations.state).thenReturn(const TvListEmpty());
    when(() => watchlistStatus.state).thenReturn(const TvWatchlistState());
  });

  Widget makeTestable(Widget body) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnTheAirTvBloc>.value(value: onTheAir),
        BlocProvider<PopularTvBloc>.value(value: popular),
        BlocProvider<TopRatedTvBloc>.value(value: topRated),
        BlocProvider<WatchlistTvBloc>.value(value: watchlist),
        BlocProvider<TvDetailBloc>.value(value: detail),
        BlocProvider<TvRecommendationsBloc>.value(value: recommendations),
        BlocProvider<TvWatchlistBloc>.value(value: watchlistStatus),
        BlocProvider<SearchTvBloc>.value(value: search),
        BlocProvider<TvSeasonDetailBloc>.value(value: season),
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

  group('HomeTvPage', () {
    testWidgets('should fetch the three TV series lists on start', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable(HomeTvPage()));

      for (final bloc in <TvListBloc>[onTheAir, popular, topRated]) {
        verify(() => bloc.add(const FetchTv())).called(1);
      }
    });

    testWidgets('should show posters, spinner and error per section', (
      tester,
    ) async {
      when(() => onTheAir.state).thenReturn(TvListHasData(testTvList));
      when(() => popular.state).thenReturn(const TvListLoading());
      when(() => topRated.state).thenReturn(const TvListError('Failed'));

      await tester.pumpWidget(makeTestable(HomeTvPage()));

      expect(find.text('On The Air'), findsOneWidget);
      expect(find.text('See More'), findsNWidgets(3));
      expect(find.byKey(const Key('tv_poster_1399')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('Failed'), findsOneWidget);
    });

    for (final (index, route) in [
      (0, onTheAirTvRoute),
      (1, popularTvRoute),
      (2, topRatedTvRoute),
    ]) {
      testWidgets('See More #$index should open $route', (tester) async {
        await tester.pumpWidget(makeTestable(HomeTvPage()));
        await tester.tap(find.text('See More').at(index));
        await settle(tester);

        expect(pushed.last.name, route);
      });
    }

    testWidgets('search action and poster tap should navigate', (tester) async {
      when(() => onTheAir.state).thenReturn(TvListHasData(testTvList));
      await tester.pumpWidget(makeTestable(HomeTvPage()));

      await tester.tap(find.byKey(const Key('tv_poster_1399')));
      await settle(tester);
      expect(pushed.last.name, tvDetailRoute);
      expect(pushed.last.arguments, 1399);

      Navigator.of(tester.element(find.text('route $tvDetailRoute'))).pop();
      await settle(tester);
      await tester.tap(find.byTooltip('Search TV series'));
      await settle(tester);
      expect(pushed.last.name, searchTvRoute);
    });
  });

  for (final (name, page, bloc) in [
    ('OnTheAirTvPage', OnTheAirTvPage(), () => onTheAir as TvListBloc),
    ('PopularTvPage', PopularTvPage(), () => popular as TvListBloc),
    ('TopRatedTvPage', TopRatedTvPage(), () => topRated as TvListBloc),
  ]) {
    group(name, () {
      testWidgets('should fetch TV series and show a spinner while loading', (
        tester,
      ) async {
        when(() => bloc().state).thenReturn(const TvListLoading());
        await tester.pumpWidget(makeTestable(page));

        verify(() => bloc().add(const FetchTv())).called(1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should list TV series cards and open the detail on tap', (
        tester,
      ) async {
        when(() => bloc().state).thenReturn(TvListHasData(testTvList));
        await tester.pumpWidget(makeTestable(page));

        expect(find.byType(TvCard), findsOneWidget);
        expect(find.text('Game of Thrones'), findsOneWidget);

        await tester.tap(find.byType(TvCard));
        await settle(tester);
        expect(pushed.last.name, tvDetailRoute);
      });

      testWidgets('should show the error message', (tester) async {
        when(() => bloc().state).thenReturn(const TvListError('Oops'));
        await tester.pumpWidget(makeTestable(page));

        expect(find.byKey(const Key('error_message')), findsOneWidget);
        expect(find.text('Oops'), findsOneWidget);
      });
    });
  }

  group('SearchTvPage', () {
    testWidgets('typing should dispatch the query', (tester) async {
      await tester.pumpWidget(makeTestable(SearchTvPage()));
      await tester.enterText(find.byType(TextField), 'game of thrones');

      verify(() => search.add(const OnTvQueryChanged('game of thrones')))
          .called(1);
    });

    testWidgets('should show results, empty message and spinner', (
      tester,
    ) async {
      when(() => search.state).thenReturn(TvListHasData(testTvList));
      await tester.pumpWidget(makeTestable(SearchTvPage()));
      expect(find.byType(TvCard), findsOneWidget);

      when(() => search.state).thenReturn(const TvListHasData(<Tv>[]));
      await tester.pumpWidget(makeTestable(const SearchTvPage(key: Key('b'))));
      expect(find.text('No TV series found'), findsOneWidget);

      when(() => search.state).thenReturn(const TvListLoading());
      await tester.pumpWidget(makeTestable(const SearchTvPage(key: Key('c'))));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('WatchlistTvView', () {
    testWidgets('should list watchlisted TV series or an empty message', (
      tester,
    ) async {
      when(() => watchlist.state).thenReturn(TvListHasData([testWatchlistTv]));
      await tester.pumpWidget(makeTestable(Scaffold(body: WatchlistTvView())));
      expect(find.byType(TvCard), findsOneWidget);

      when(() => watchlist.state).thenReturn(const TvListHasData(<Tv>[]));
      await tester.pumpWidget(
        makeTestable(const Scaffold(body: WatchlistTvView(key: Key('e')))),
      );
      expect(find.text('No TV series in your watchlist yet'), findsOneWidget);
    });
  });

  group('TvDetailPage', () {
    testWidgets('should request detail, recommendations and status', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable(TvDetailPage(id: 1)));

      verify(() => detail.add(const FetchTvDetail(1))).called(1);
      verify(() => recommendations.add(const FetchTvRecommendations(1)))
          .called(1);
      verify(() => watchlistStatus.add(const LoadTvWatchlistStatus(1)))
          .called(1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show the error message', (tester) async {
      when(() => detail.state).thenReturn(const TvDetailError('Not found'));
      await tester.pumpWidget(makeTestable(const TvDetailPage(id: 1)));

      expect(find.text('Not found'), findsOneWidget);
    });

    testWidgets('should show the TV series detail and recommendations', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(TvDetailHasData(testTvDetail));
      when(() => recommendations.state).thenReturn(TvListHasData(testTvList));
      await tester.pumpWidget(makeTestable(const TvDetailPage(id: 1)));

      expect(find.text('name'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('1 Season(s), 10 Episode(s)'), findsOneWidget);
      expect(find.text('Seasons'), findsOneWidget);
      expect(find.text('Season 1'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('tv_poster_1399')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('tv_poster_1399')));
      await settle(tester);
      expect(pushed.last.name, tvDetailRoute);
      expect(pushed.last.arguments, 1399);
    });

    testWidgets('should show recommendation states', (tester) async {
      when(() => detail.state).thenReturn(TvDetailHasData(testTvDetail));
      when(() => recommendations.state).thenReturn(const TvListError('x'));
      await tester.pumpWidget(makeTestable(const TvDetailPage(id: 1)));
      expect(find.text('x'), findsOneWidget);

      when(() => recommendations.state).thenReturn(const TvListHasData(<Tv>[]));
      await tester.pumpWidget(
        makeTestable(const TvDetailPage(key: Key('2'), id: 2)),
      );
      expect(find.text('No recommendations'), findsOneWidget);
    });

    testWidgets('watchlist button should add or remove the TV series', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(TvDetailHasData(testTvDetail));
      await tester.pumpWidget(makeTestable(const TvDetailPage(id: 1)));

      await tester.tap(find.byType(FilledButton));
      verify(() => watchlistStatus.add(AddTvToWatchlist(testTvDetail)))
          .called(1);

      when(() => watchlistStatus.state)
          .thenReturn(const TvWatchlistState(isAdded: true));
      await tester.pumpWidget(
        makeTestable(const TvDetailPage(key: Key('3'), id: 3)),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      verify(() => watchlistStatus.add(RemoveTvFromWatchlist(testTvDetail)))
          .called(1);
    });

    testWidgets('should show a snackbar for a successful watchlist change', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(TvDetailHasData(testTvDetail));
      whenListen(
        watchlistStatus,
        Stream.value(
          const TvWatchlistState(
            isAdded: true,
            message: TvWatchlistBloc.addSuccessMessage,
          ),
        ),
        initialState: const TvWatchlistState(),
      );
      await tester.pumpWidget(makeTestable(const TvDetailPage(id: 1)));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Added to Watchlist'), findsOneWidget);
    });

    testWidgets('should show a dialog when the watchlist change fails', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(TvDetailHasData(testTvDetail));
      whenListen(
        watchlistStatus,
        Stream.value(const TvWatchlistState(message: 'Database error')),
        initialState: const TvWatchlistState(),
      );
      await tester.pumpWidget(makeTestable(const TvDetailPage(id: 1)));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Database error'), findsOneWidget);
    });

    testWidgets('back button should close the page', (tester) async {
      when(() => detail.state).thenReturn(TvDetailHasData(testTvDetail));
      await tester.pumpWidget(
        makeTestable(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TvDetailPage(id: 1)),
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
  });

  group('TvDetailPage seasons', () {
    testWidgets('tapping a season should open the season detail route', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(TvDetailHasData(testTvDetail));
      await tester.pumpWidget(makeTestable(TvDetailPage(id: 1)));

      expect(find.text('10 Episode(s)'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('season_1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('season_1')));
      await settle(tester);

      expect(pushed.last.name, tvSeasonDetailRoute);
      final args = pushed.last.arguments as TvSeasonDetailArguments;
      expect(args.tvId, 1);
      expect(args.seasonNumber, 1);
      expect(args.seasonName, 'Season 1');
    });

    testWidgets('should show a placeholder for seasons without poster', (
      tester,
    ) async {
      when(() => detail.state).thenReturn(
        TvDetailHasData(
          testTvDetail.copyWithSeasons(const [
            Season(
              id: 9,
              name: 'Specials',
              seasonNumber: 0,
              episodeCount: 2,
              posterPath: null,
              airDate: null,
            ),
          ]),
        ),
      );
      await tester.pumpWidget(makeTestable(TvDetailPage(id: 1)));

      expect(find.text('Specials'), findsOneWidget);
      expect(find.byIcon(Icons.tv), findsOneWidget);
    });

    testWidgets('should say when there is no season information', (
      tester,
    ) async {
      when(() => detail.state)
          .thenReturn(TvDetailHasData(testTvDetail.copyWithSeasons(const [])));
      await tester.pumpWidget(makeTestable(TvDetailPage(id: 1)));

      expect(find.text('No season information'), findsOneWidget);
    });
  });

  group('TvSeasonDetailPage', () {
    const args = TvSeasonDetailArguments(
      tvId: 1,
      seasonNumber: 1,
      seasonName: 'Season 1',
    );

    testWidgets('should request the season and show a spinner', (tester) async {
      await tester.pumpWidget(makeTestable(TvSeasonDetailPage(args: args)));

      verify(
        () => season.add(const FetchTvSeasonDetail(tvId: 1, seasonNumber: 1)),
      ).called(1);
      expect(find.text('Season 1'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should list the episodes of the season', (tester) async {
      when(() => season.state)
          .thenReturn(const TvSeasonDetailHasData(testSeasonDetail));
      await tester.pumpWidget(makeTestable(TvSeasonDetailPage(args: args)));

      expect(find.text('1 Episode(s) • 2011-04-17'), findsOneWidget);
      expect(find.text('season overview'), findsOneWidget);
      expect(find.byType(EpisodeCard), findsOneWidget);
      expect(find.text('Episode 1: Winter Is Coming'), findsOneWidget);
      expect(find.text('2011-04-17 • 62 min • ★ 8.2'), findsOneWidget);
    });

    testWidgets('should handle a season without optional data', (tester) async {
      when(() => season.state).thenReturn(
        const TvSeasonDetailHasData(
          SeasonDetail(
            id: 1,
            name: 'Specials',
            seasonNumber: 0,
            overview: '',
            posterPath: null,
            airDate: null,
            episodes: [
              Episode(
                id: 1,
                name: 'Pilot',
                episodeNumber: 1,
                overview: '',
                stillPath: null,
                airDate: null,
                runtime: null,
                voteAverage: 0,
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(makeTestable(TvSeasonDetailPage(args: args)));

      expect(find.text('1 Episode(s)'), findsOneWidget);
      expect(find.text('Episode 1: Pilot'), findsOneWidget);
      expect(find.text('★ 0.0'), findsOneWidget);
    });

    testWidgets('should show the error message', (tester) async {
      when(() => season.state)
          .thenReturn(const TvSeasonDetailError('Server Failure'));
      await tester.pumpWidget(makeTestable(TvSeasonDetailPage(args: args)));

      expect(find.byKey(const Key('error_message')), findsOneWidget);
      expect(find.text('Server Failure'), findsOneWidget);
    });
  });
}
