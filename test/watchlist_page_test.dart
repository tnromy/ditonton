import 'package:core/core.dart';
import 'package:ditonton/app.dart';
import 'package:ditonton/injection.dart';
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

  Future<NavigatorState> openWatchlist(WidgetTester tester) async {
    await tester.pumpWidget(const DitontonApp());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(watchlistRoute);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    return navigator;
  }

  testWidgets('should show Movies and TV Series tabs and fetch both', (
    tester,
  ) async {
    await openWatchlist(tester);

    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('TV Series'), findsOneWidget);
    verify(() => blocs.watchlistMovies.add(const FetchMovies())).called(1);
    verify(() => blocs.watchlistTv.add(const FetchTv())).called(1);
  });

  testWidgets('should switch to the TV Series tab', (tester) async {
    when(() => blocs.watchlistTv.state).thenReturn(const TvListHasData([]));
    await openWatchlist(tester);

    await tester.tap(find.text('TV Series'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(WatchlistTvView), findsOneWidget);
    expect(find.text('No TV series in your watchlist yet'), findsOneWidget);
  });

  testWidgets('should refresh both lists when coming back to the page', (
    tester,
  ) async {
    final navigator = await openWatchlist(tester);

    navigator.pushNamed(aboutRoute);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verify(() => blocs.watchlistMovies.add(const FetchMovies())).called(2);
    verify(() => blocs.watchlistTv.add(const FetchTv())).called(2);
  });
}
