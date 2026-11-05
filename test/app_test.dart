import 'package:about/about.dart';
import 'package:core/core.dart';
import 'package:ditonton/app.dart';
import 'package:ditonton/injection.dart';
import 'package:ditonton/presentation/pages/watchlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie/movie.dart';
import 'package:tv/tv.dart';

import 'helpers/mock_blocs.dart';

void main() {
  late MockBlocs blocs;

  setUpAll(MockBlocs.registerFallbacks);

  setUp(() async {
    blocs = MockBlocs()..stubInitialStates();
    await blocs.register();
  });

  tearDown(() => locator.reset());

  Future<void> openRoute(
    WidgetTester tester,
    String route, {
    Object? arguments,
  }) async {
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(route, arguments: arguments);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('should start on the movie home page and notify observers', (
    tester,
  ) async {
    final observer = _RecordingObserver();
    await tester.pumpWidget(DitontonApp(navigatorObservers: [observer]));

    expect(find.byType(HomeMoviePage), findsOneWidget);
    expect(observer.pushed, isNotEmpty);
    verify(() => blocs.nowPlaying.add(const FetchMovies())).called(1);
  });

  final routes = <String, (Object?, Type)>{
    homeMovieRoute: (null, HomeMoviePage),
    popularMoviesRoute: (null, PopularMoviesPage),
    topRatedMoviesRoute: (null, TopRatedMoviesPage),
    movieDetailRoute: (1, MovieDetailPage),
    searchMoviesRoute: (null, SearchMoviesPage),
    homeTvRoute: (null, HomeTvPage),
    onTheAirTvRoute: (null, OnTheAirTvPage),
    popularTvRoute: (null, PopularTvPage),
    topRatedTvRoute: (null, TopRatedTvPage),
    tvDetailRoute: (1, TvDetailPage),
    tvSeasonDetailRoute: (
      const TvSeasonDetailArguments(
        tvId: 1,
        seasonNumber: 1,
        seasonName: 'Season 1',
      ),
      TvSeasonDetailPage,
    ),
    searchTvRoute: (null, SearchTvPage),
    watchlistRoute: (null, WatchlistPage),
    aboutRoute: (null, AboutPage),
  };

  routes.forEach((route, value) {
    final (arguments, page) = value;
    testWidgets('route $route should open $page', (tester) async {
      await tester.pumpWidget(const DitontonApp());
      await openRoute(tester, route, arguments: arguments);

      expect(find.byType(page), findsWidgets);
    });
  });

  testWidgets('unknown route should show a not found page', (tester) async {
    await tester.pumpWidget(const DitontonApp());
    await openRoute(tester, '/unknown');

    expect(find.text('Page not found :('), findsOneWidget);
  });

  test('list pages should use a cupertino transition', () {
    expect(
      onGenerateRoute(const RouteSettings(name: searchTvRoute)),
      isA<PageRoute<dynamic>>(),
    );
    expect(
      onGenerateRoute(const RouteSettings(name: aboutRoute)),
      isA<MaterialPageRoute<dynamic>>(),
    );
  });
}

class _RecordingObserver extends NavigatorObserver {
  final pushed = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      pushed.add(route);
}
